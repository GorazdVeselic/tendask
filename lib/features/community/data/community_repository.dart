import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import 'community_models.dart';
import 'community_stats.dart';

/// Fetches rows of a public aggregate table filtered by equality on the given
/// columns. Injected so the repository stays testable without a live Supabase.
typedef RemoteAggFetch =
    Future<List<Map<String, dynamic>>> Function(
      String table,
      Map<String, String> filter,
    );

/// Reads the public community aggregate slices (activity_recent / season /
/// frequency / bucket_population) and caches each slice on-device for the local
/// day (`community_cache`). Repeat opens read locally (0 cloud), and offline
/// shows yesterday's slice — the weather-cache pattern (skupnost-agregacija.md
/// §12.4). This is the one repository that queries Supabase directly: aggregates
/// are public-read, RLS-gated, and not part of the normal user-row sync.
class CommunityRepository {
  CommunityRepository(
    this._db,
    this._fetch, {
    this._clock = const SystemClock(),
  });

  final AppDatabase _db;
  // null = fully offline / no backend → serve stale cache only.
  final RemoteAggFetch? _fetch;
  final Clock _clock;

  /// Finest bucket (r7 → r6 → r5 → climate) whose population clears the privacy
  /// threshold, then its "This week" feed. Widens the geography one level at a
  /// time, never mixing (§7.4). null = not enough gardeners at any level.
  Future<CommunityFeed?> feed({required List<Bucket> buckets}) async {
    for (final bucket in buckets) {
      final population = await bucketPopulation(bucket: bucket);
      if (population == null || population < kCommunityPrivacyMin) continue;
      // Whole bucket slice in one daily pull (§12.4): site rows, plant rows and
      // the legacy superset arrive together and are split locally.
      final rows = await _cachedRows('activity_recent', {
        'resolution': bucket.resolution.name,
        'bucket_key': bucket.key,
      });
      if (rows == null) continue;
      // Emptiness is judged on the cohorts, not the raw slice: a bucket holding
      // only superset/malformed rows has nothing to show and must widen too.
      final items = _feedItems(rows, population);
      if (items.isEmpty) continue;
      return CommunityFeed(
        bucket: bucket,
        population: population,
        items: items,
      );
    }
    return null;
  }

  /// Season curve for one task type in ONE cohort at ONE resolution level — the
  /// caller widens the level but never swaps the cohort (§7.4). null = the group
  /// is hidden or empty at this level.
  Future<SeasonCurve?> seasonCurve({
    required Bucket bucket,
    required String taskTypeId,
    required String cohort,
  }) async {
    final rows = await _cachedRows('activity_season', {
      'resolution': bucket.resolution.name,
      'bucket_key': bucket.key,
      'task_type_id': taskTypeId,
      'plant_id': cohort,
    });
    if (rows == null) return null;
    return buildSeasonCurve(
      rows,
      bucket: bucket,
      currentYear: _clock.now().toLocal().year,
    );
  }

  /// Frequency stats for one task type in ONE cohort at ONE resolution level.
  /// null = the group is hidden or empty at this level.
  Future<FrequencyStats?> frequency({
    required Bucket bucket,
    required String taskTypeId,
    required String cohort,
  }) async {
    final rows = await _cachedRows('activity_frequency', {
      'resolution': bucket.resolution.name,
      'bucket_key': bucket.key,
      'task_type_id': taskTypeId,
      'plant_id': cohort,
    });
    if (rows == null) return null;
    return parseFrequency(
      rows,
      bucket: bucket,
      seasonYear: _clock.now().toLocal().year,
    );
  }

  /// My own first completion of [taskTypeId] in [cohort] this season — the "you"
  /// marker. Season = calendar year, mirroring the cron's
  /// `extract(year from local_day)`; cohort membership mirrors `agg_event`
  /// (catalog plant subject → that plant, otherwise site work, so a task on a
  /// private custom plant counts as site here too). The returned date is in
  /// local time, the flavour [isoWeek] expects for the marker.
  /// LOCAL only: this never leaves the device. null = not started yet this year.
  Future<DateTime?> myFirstThisSeason(
    String taskTypeId, {
    required String cohort,
  }) async {
    final year = _clock.now().toLocal().year;
    final from = DateTime(year).toUtc();
    final until = DateTime(year + 1).toUtc();

    final tasks =
        await (_db.select(_db.tasks)
              ..where(
                (t) =>
                    t.taskTypeId.equals(taskTypeId) &
                    t.status.equalsValue(TaskStatus.done) &
                    t.deleted.equals(false) &
                    t.date.isBiggerOrEqualValue(from) &
                    t.date.isSmallerThanValue(until),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.date)]))
            .get();
    if (tasks.isEmpty) return null;

    final catalogPlantsByTask = await _catalogPlantsByTask(
      tasks.map((t) => t.id).toList(),
    );
    for (final task in tasks) {
      final plants = catalogPlantsByTask[task.id] ?? const <String>{};
      final inCohort = cohort == kCommunityCohortSite
          ? plants.isEmpty
          : plants.contains(cohort);
      if (inCohort) return task.date;
    }
    return null;
  }

  /// Catalog plant ids per task (custom plants excluded, like `agg_event`).
  /// Two queries for the whole set, not one per task.
  Future<Map<String, Set<String>>> _catalogPlantsByTask(
    List<String> taskIds,
  ) async {
    final subjects =
        await (_db.select(_db.taskSubjects)..where(
              (s) => s.taskId.isIn(taskIds) & s.deleted.equals(false),
            ))
            .get();
    final userPlantIds = subjects
        .map((s) => s.userPlantId)
        .nonNulls
        .toList();
    if (userPlantIds.isEmpty) return const {};

    final userPlants =
        await (_db.select(_db.userPlants)..where(
              (p) => p.id.isIn(userPlantIds) & p.deleted.equals(false),
            ))
            .get();
    final plantOfUserPlant = <String, String>{};
    for (final userPlant in userPlants) {
      final plantId = userPlant.plantId;
      if (userPlant.isCustom || plantId == null) continue;
      plantOfUserPlant[userPlant.id] = plantId;
    }

    final out = <String, Set<String>>{};
    for (final subject in subjects) {
      final plantId = plantOfUserPlant[subject.userPlantId];
      if (plantId != null) (out[subject.taskId] ??= {}).add(plantId);
    }
    return out;
  }

  /// Distinct eligible gardeners in a bucket. null = below the privacy threshold
  /// (RLS hides the row) or offline with no cache — the caller falls back coarser.
  Future<int?> bucketPopulation({required Bucket bucket}) async {
    final rows = await _cachedRows('bucket_population', {
      'resolution': bucket.resolution.name,
      'bucket_key': bucket.key,
    });
    if (rows == null || rows.isEmpty) return null;
    final value = rows.first['distinct_users'];
    return value is num ? value.toInt() : null;
  }

  /// Ranked feed items, one per cohort. The legacy `plant_id = ''` rows are
  /// skipped: they are the superset of the cohorts below them, so ranking them
  /// alongside would double-count and blend different acts (§7.4). A row missing
  /// its type or count is dropped rather than thrown on (tolerant parser rule).
  List<CommunityFeedItem> _feedItems(
    List<Map<String, dynamic>> rows,
    int population,
  ) {
    final usable = [
      for (final row in rows)
        if (row['task_type_id'] is String &&
            row['distinct_users_7d'] is num &&
            row['plant_id'] is String &&
            (row['plant_id'] as String).isNotEmpty)
          (
            taskTypeId: row['task_type_id'] as String,
            cohort: row['plant_id'] as String,
            users: (row['distinct_users_7d'] as num).toInt(),
          ),
    ]..sort((a, b) => b.users.compareTo(a.users));

    final perType = <String, int>{};
    final items = <CommunityFeedItem>[];
    for (final row in usable) {
      final taken = perType[row.taskTypeId] ?? 0;
      if (taken >= kCommunityFeedMaxPerType) continue;
      perType[row.taskTypeId] = taken + 1;
      items.add(
        CommunityFeedItem(
          taskTypeId: row.taskTypeId,
          cohort: row.cohort,
          distinctUsers7d: row.users,
          intensity: feedIntensity(row.users, population),
        ),
      );
      if (items.length == kCommunityFeedLimit) break;
    }
    return items;
  }

  /// Reads the cache slice; if today's is missing and online, fetches it, stores
  /// it, and returns it. On a fetch failure or offline, returns the stale slice
  /// (graceful degrade), else null. The table plus the whole filter IS the cache
  /// key, so two slices that differ in any column can never collide and no
  /// caller has to remember to name its own scope.
  Future<List<Map<String, dynamic>>?> _cachedRows(
    String table,
    Map<String, String> filter,
  ) async {
    final columns = filter.keys.toList()..sort();
    final key = [table, for (final c in columns) '$c=${filter[c]}'].join('|');
    final cached =
        await (_db.select(
          _db.communityCaches,
        )..where((c) => c.key.equals(key))).getSingleOrNull();
    final today = startOfDay(_clock.now().toLocal());
    final fresh =
        cached != null && !startOfDay(cached.fetchedAt.toLocal()).isBefore(today);
    if (fresh) return _decode(cached.payload);
    if (_fetch == null) return cached == null ? null : _decode(cached.payload);
    try {
      final data = await _fetch(table, filter);
      await _db
          .into(_db.communityCaches)
          .insertOnConflictUpdate(
            CommunityCachesCompanion.insert(
              key: key,
              payload: jsonEncode(data),
              fetchedAt: _clock.now(),
            ),
          );
      return data;
    } catch (_) {
      // Network fail is a normal offline state, not an error path: fall back to
      // the last known slice rather than surfacing an exception.
      return cached == null ? null : _decode(cached.payload);
    }
  }

  List<Map<String, dynamic>> _decode(String payload) =>
      (jsonDecode(payload) as List).cast<Map<String, dynamic>>();
}

/// Maps a task type's share of the bucket's gardeners over the 7-day window to a
/// qualitative label (§7.1). Pure so the feed's intensity is unit-testable.
CommunityIntensity feedIntensity(int users, int population) {
  if (population <= 0) return CommunityIntensity.rare;
  final share = users / population;
  if (share >= kCommunityIntensityOften) return CommunityIntensity.often;
  if (share >= kCommunityIntensitySome) return CommunityIntensity.some;
  return CommunityIntensity.rare;
}
