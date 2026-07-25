import 'dart:convert';

import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import 'community_models.dart';

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
      final rows = await _cachedRows('feed', bucket, {
        'resolution': bucket.resolution.name,
        'bucket_key': bucket.key,
        'plant_id': '',
      }, 'activity_recent');
      if (rows == null || rows.isEmpty) continue;
      return CommunityFeed(
        bucket: bucket,
        population: population,
        items: _feedItems(rows, population),
      );
    }
    return null;
  }

  /// Distinct eligible gardeners in a bucket. null = below the privacy threshold
  /// (RLS hides the row) or offline with no cache — the caller falls back coarser.
  Future<int?> bucketPopulation({required Bucket bucket}) async {
    final rows = await _cachedRows('pop', bucket, {
      'resolution': bucket.resolution.name,
      'bucket_key': bucket.key,
    }, 'bucket_population');
    if (rows == null || rows.isEmpty) return null;
    return (rows.first['distinct_users'] as num).toInt();
  }

  List<CommunityFeedItem> _feedItems(
    List<Map<String, dynamic>> rows,
    int population,
  ) {
    final sorted = [...rows]
      ..sort(
        (a, b) => (b['distinct_users_7d'] as num).toInt().compareTo(
          (a['distinct_users_7d'] as num).toInt(),
        ),
      );
    return [
      for (final r in sorted.take(kCommunityFeedLimit))
        CommunityFeedItem(
          taskTypeId: r['task_type_id'] as String,
          plantId: (r['plant_id'] as String?) ?? '',
          distinctUsers7d: (r['distinct_users_7d'] as num).toInt(),
          intensity: feedIntensity(
            (r['distinct_users_7d'] as num).toInt(),
            population,
          ),
        ),
    ];
  }

  /// Reads the cache slice; if today's is missing and online, fetches it, stores
  /// it, and returns it. On a fetch failure or offline, returns the stale slice
  /// (graceful degrade), else null. `metric` + bucket form the cache key so the
  /// feed and population slices never collide.
  Future<List<Map<String, dynamic>>?> _cachedRows(
    String metric,
    Bucket bucket,
    Map<String, String> filter,
    String table,
  ) async {
    final key = '$metric|${bucket.resolution.name}|${bucket.key}|';
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
