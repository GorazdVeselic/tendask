import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import 'community_cohort.dart';
import 'community_models.dart';
import 'community_stats.dart';

/// Fetches rows of a public aggregate table filtered on the given columns: a
/// String value means equality, a `List<String>` means "any of these" — the
/// bulk slice read behind the standings list (§12.4). Injected so the repository
/// stays testable without a live Supabase.
typedef RemoteAggFetch =
    Future<List<Map<String, dynamic>>> Function(
      String table,
      Map<String, Object> filter,
    );

/// A cached slice and when it was read from the cloud. Most callers only want
/// the rows; the landing feed also dates them.
typedef _Slice = ({List<Map<String, dynamic>> rows, DateTime fetchedAt});

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

  /// How many times the user has asked for fresh data, and the count each slice
  /// was last fetched under. A counter rather than a timestamp on purpose: a
  /// refresh moments after a fetch shares its second (drift stores seconds), and
  /// a time comparison would call the slice fresh and swallow the gesture.
  /// Both live in memory — a refresh is a gesture inside one session, and a
  /// restart already refetches through the ordinary daily rule.
  int _refreshEpoch = 0;
  final Map<String, int> _fetchedUnderEpoch = {};

  /// Makes the next read of every slice go to the network. Deliberately does NOT
  /// touch the cached rows: a refresh that finds no signal must still degrade to
  /// the last known slice, with its real date (P8), not to an empty screen.
  void requestRefresh() => _refreshEpoch++;

  /// The profile's aggregation buckets, finest → coarsest. A stream so moving
  /// the garden (new H3 cells) re-resolves the scope without a restart.
  Stream<List<Bucket>> watchBuckets(String userId) =>
      (_db.select(_db.profiles)..where((p) => p.userId.equals(userId)))
          .watchSingleOrNull()
          .map((profile) {
            if (profile == null) return const <Bucket>[];
            final keys = {
              CommunityResolution.r7: profile.h3R7,
              CommunityResolution.r6: profile.h3R6,
              CommunityResolution.r5: profile.h3R5,
              CommunityResolution.climate: profile.climateBucket,
            };
            return [
              for (final level in keys.entries)
                if (level.value case final key?)
                  Bucket(resolution: level.key, key: key),
            ];
          });

  /// Finest bucket (r7 → r6 → r5 → climate) whose population clears the privacy
  /// threshold, then its "This week" feed. Widens the geography one level at a
  /// time, never mixing (§7.4). null = not enough gardeners at any level.
  Future<CommunityFeed?> feed({required List<Bucket> buckets}) async {
    for (final bucket in buckets) {
      final scope = {
        'resolution': bucket.resolution.name,
        'bucket_key': bucket.key,
      };
      final populationSlice = await _cachedSlice('bucket_population', scope);
      if (populationSlice == null) continue;
      final population = _populationOf(populationSlice.rows);
      if (population == null || population < kCommunityPrivacyMin) continue;
      // Whole bucket slice in one daily pull (§12.4): site rows, plant rows and
      // the legacy superset arrive together and are split locally.
      final slice = await _cachedSlice('activity_recent', scope);
      if (slice == null) continue;
      // Emptiness is judged on the cohorts, not the raw slice: a bucket holding
      // only superset/malformed rows has nothing to show and must widen too.
      final items = _feedItems(slice.rows, population);
      if (items.isEmpty) continue;
      return CommunityFeed(
        bucket: bucket,
        population: population,
        items: items,
        fetchedAt: populationSlice.fetchedAt.isBefore(slice.fetchedAt)
            ? populationSlice.fetchedAt
            : slice.fetchedAt,
      );
    }
    return null;
  }

  /// Whether the device has ever read this scope from the cloud. Without a
  /// slice, an empty answer is a fact about the device, not about the
  /// neighbourhood — and the screen must not claim the latter.
  Future<bool> hasCachedScope(List<Bucket> buckets) async {
    for (final bucket in buckets) {
      final key = _cacheKey('bucket_population', {
        'resolution': bucket.resolution.name,
        'bucket_key': bucket.key,
      });
      if (await _readCache(key) != null) return true;
    }
    return false;
  }

  /// The "this week" line for ONE cohort at ONE resolution level, read from the
  /// same daily `activity_recent` slice the feed already caches — no extra
  /// request. null = this cohort is not in the slice at this level (nobody, or
  /// below the RLS threshold), so the caller widens.
  Future<CommunityWeekly?> recentActivity({
    required Bucket bucket,
    required String taskTypeId,
    required String cohort,
  }) async {
    final population = await bucketPopulation(bucket: bucket);
    if (population == null || population < kCommunityPrivacyMin) return null;
    final rows = await _cachedRows('activity_recent', {
      'resolution': bucket.resolution.name,
      'bucket_key': bucket.key,
    });
    if (rows == null) return null;
    for (final row in rows) {
      if (row['task_type_id'] != taskTypeId || row['plant_id'] != cohort) {
        continue;
      }
      final users = row['distinct_users_7d'];
      if (users is! num) continue;
      return CommunityWeekly(
        bucket: bucket,
        distinctUsers7d: users.toInt(),
        intensity: feedIntensity(users.toInt(), population),
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
    if (rows == null || rows.length >= kCommunityRowLimit) return null;
    return buildSeasonCurve(
      rows,
      bucket: bucket,
      currentYear: _clock.now().toLocal().year,
    );
  }

  /// Season curves for MANY cohorts at once, resolved like [seasonCurve] but
  /// costing **one request per resolution level instead of one per cohort**
  /// (§12.4): the standings list would otherwise open the day with N round
  /// trips. Cohorts absent from the returned map have no level with enough
  /// gardeners. Pairs are `(taskTypeId, cohort)`.
  Future<Map<(String, String), SeasonCurve>> seasonCurves({
    required List<Bucket> buckets,
    required List<(String, String)> pairs,
  }) async {
    final out = <(String, String), SeasonCurve>{};
    for (final bucket in buckets) {
      final missing = [
        for (final pair in pairs)
          if (!out.containsKey(pair)) pair,
      ];
      if (missing.isEmpty) break;
      await _primeSeasonCache(bucket, missing);
      for (final pair in missing) {
        final curve = await seasonCurve(
          bucket: bucket,
          taskTypeId: pair.$1,
          cohort: pair.$2,
        );
        if (curve != null && curve.pooledTotal >= kCommunityPrivacyMin) {
          out[pair] = curve;
        }
      }
    }
    return out;
  }

  /// Pulls the season slice for [pairs] at [bucket] in ONE request and stores it
  /// **split per pair, under the very keys [seasonCurve] reads** — so the list
  /// costs one request per level, and opening a detail afterwards costs nothing.
  /// A pair with no rows caches an empty slice: "nobody here" is an answer worth
  /// remembering for the day, not a reason to ask again.
  ///
  /// Silent no-op when every pair already has today's slice, when offline, or on
  /// a failed fetch — the per-pair reads then serve whatever stale rows exist.
  Future<void> _primeSeasonCache(
    Bucket bucket,
    List<(String, String)> pairs,
  ) async {
    if (_fetch == null) return;
    final keys = {
      for (final pair in pairs)
        pair: _cacheKey('activity_season', {
          'resolution': bucket.resolution.name,
          'bucket_key': bucket.key,
          'task_type_id': pair.$1,
          'plant_id': pair.$2,
        }),
    };
    final stale = [
      for (final pair in pairs)
        if (!_isFresh(keys[pair]!, await _readCache(keys[pair]!))) pair,
    ];
    if (stale.isEmpty) return;

    final List<Map<String, dynamic>> data;
    try {
      data = await _fetch('activity_season', {
        'resolution': bucket.resolution.name,
        'bucket_key': bucket.key,
        'task_type_id': {for (final pair in stale) pair.$1}.toList(),
      });
    } catch (_) {
      return;
    }
    // A capped slice is missing rows we cannot identify, and splitting it would
    // cache a truncated curve per pair. Drop it and let the per-pair reads fetch
    // their own exact (tiny) slices — slower, but never a re-scaled percentage.
    if (data.length >= kCommunityRowLimit) return;
    final now = _clock.now();
    for (final pair in stale) {
      await _writeCache(keys[pair]!, [
        for (final row in data)
          if (row['task_type_id'] == pair.$1 && row['plant_id'] == pair.$2) row,
      ], now);
    }
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

  /// My own record for [taskTypeId] in [cohort] this season: the first date (the
  /// "you" marker) and how many times I did it (the "you" bar). Season =
  /// calendar year, mirroring the cron's `extract(year from local_day)`; cohort
  /// membership mirrors `agg_event` (catalog plant subject → that plant,
  /// otherwise site work, so a task on a private custom plant counts as site
  /// here too). Dates are local, the flavour [isoWeek] expects.
  ///
  /// A stream, so logging a task while the screen is open moves the marker.
  /// LOCAL only: this never leaves the device.
  Stream<MySeason> watchMySeason(
    String taskTypeId, {
    required String cohort,
  }) => _watchDoneThisSeason(taskTypeId: taskTypeId).asyncMap((tasks) async {
    final seasons = await _mySeasonsOf(tasks);
    return seasons[(taskTypeId, cohort)] ??
        const MySeason(first: null, count: 0);
  });

  /// Every (task type, cohort) I did this season — the "where you stand" list.
  /// Same rule and same season as [watchMySeason]; a task on two plants counts
  /// in both cohorts, exactly as `agg_event` records it. LOCAL only.
  Stream<Map<(String, String), MySeason>> watchMySeasons() =>
      _watchDoneThisSeason().asyncMap(_mySeasonsOf);

  /// Completed, undeleted tasks of the current season, oldest first (so the
  /// first row of a group is its first execution).
  Stream<List<Task>> _watchDoneThisSeason({String? taskTypeId}) {
    final year = _clock.now().toLocal().year;
    final from = DateTime(year).toUtc();
    final until = DateTime(year + 1).toUtc();

    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.status.equalsValue(TaskStatus.done) &
                t.deleted.equals(false) &
                t.date.isBiggerOrEqualValue(from) &
                t.date.isSmallerThanValue(until) &
                (taskTypeId == null
                    ? const Constant(true)
                    : t.taskTypeId.equals(taskTypeId)),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .watch();
  }

  Future<Map<(String, String), MySeason>> _mySeasonsOf(
    List<Task> tasks,
  ) async {
    if (tasks.isEmpty) return const {};
    final catalogPlantsByTask = await _catalogPlantsByTask(
      tasks.map((t) => t.id).toList(),
    );
    final out = <(String, String), MySeason>{};
    for (final task in tasks) {
      final plants = catalogPlantsByTask[task.id] ?? const <String>{};
      final cohorts = plants.isEmpty ? const {kCommunityCohortSite} : plants;
      for (final cohort in cohorts) {
        final previous = out[(task.taskTypeId, cohort)];
        out[(task.taskTypeId, cohort)] = MySeason(
          // The query is ordered by date, so the first row seen is the first
          // execution.
          first: previous?.first ?? task.date,
          count: (previous?.count ?? 0) + 1,
        );
      }
    }
    return out;
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
      if (catalogPlantOf(userPlant) case final plantId?) {
        plantOfUserPlant[userPlant.id] = plantId;
      }
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
    return rows == null ? null : _populationOf(rows);
  }

  int? _populationOf(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;
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
  Future<_Slice?> _cachedSlice(
    String table,
    Map<String, String> filter,
  ) async {
    final key = _cacheKey(table, filter);
    final cached = await _readCache(key);
    final local = cached == null
        ? null
        : (rows: _decode(cached.payload), fetchedAt: cached.fetchedAt);
    if (_isFresh(key, cached) || _fetch == null) return local;
    try {
      final now = _clock.now();
      final data = await _fetch(table, filter);
      await _writeCache(key, data, now);
      return (rows: data, fetchedAt: now);
    } catch (_) {
      // Network fail is a normal offline state, not an error path: fall back to
      // the last known slice rather than surfacing an exception.
      return local;
    }
  }

  Future<List<Map<String, dynamic>>?> _cachedRows(
    String table,
    Map<String, String> filter,
  ) async => (await _cachedSlice(table, filter))?.rows;

  String _cacheKey(String table, Map<String, String> filter) {
    final columns = filter.keys.toList()..sort();
    return [table, for (final c in columns) '$c=${filter[c]}'].join('|');
  }

  Future<CommunityCache?> _readCache(String key) => (_db.select(
    _db.communityCaches,
  )..where((c) => c.key.equals(key))).getSingleOrNull();

  /// A slice not yet refetched under the current refresh epoch is stale whatever
  /// its date says. On a cold start the map is empty and the epoch is 0, so the
  /// ordinary once-a-day rule applies unchanged.
  bool _isFresh(String key, CommunityCache? cached) {
    if (cached == null) return false;
    if ((_fetchedUnderEpoch[key] ?? 0) < _refreshEpoch) return false;
    return !startOfDay(
      cached.fetchedAt.toLocal(),
    ).isBefore(startOfDay(_clock.now().toLocal()));
  }

  Future<void> _writeCache(
    String key,
    List<Map<String, dynamic>> data,
    DateTime now,
  ) async {
    _fetchedUnderEpoch[key] = _refreshEpoch;
    await _db
        .into(_db.communityCaches)
        .insertOnConflictUpdate(
          CommunityCachesCompanion.insert(
            key: key,
            payload: jsonEncode(data),
            fetchedAt: now,
          ),
        );
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
