import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/community/application/community_providers.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_repository.dart';

class _FakeClock implements Clock {
  const _FakeClock();
  @override
  DateTime now() => DateTime(2026, 6, 1, 9);
}

const _r7 = Bucket(resolution: CommunityResolution.r7, key: 'cellA');
const _r6 = Bucket(resolution: CommunityResolution.r6, key: 'cellB');
const _climate = Bucket(resolution: CommunityResolution.climate, key: 'e1_t5');

/// Season rows summing to [total] users, all in one past week.
List<Map<String, dynamic>> _season(int total) => [
  {'year': 2025, 'iso_week': 14, 'first_user_count': total},
];

List<Map<String, dynamic>> _frequency(int nUsers) => [
  {
    'season_year': 2026,
    'n_users': nUsers,
    'per_user_p25': 2,
    'per_user_p50': 3,
    'per_user_p75': 4,
    'unit': 'per_month',
    'hist': <String, int>{},
  },
];

void main() {
  late AppDatabase db;
  late Map<String, List<Map<String, dynamic>>> store;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = {};
  });

  tearDown(() => db.close());

  /// A container whose repository reads [store] — keyed
  /// '<table>|<resolution>|<bucket>|<task_type>|<plant>'.
  ProviderContainer container({
    List<Bucket> buckets = const [_r7, _r6, _climate],
  }) {
    final repo = CommunityRepository(db, (table, filter) async {
      final key =
          '$table|${filter['resolution']}|${filter['bucket_key']}'
          '|${filter['task_type_id']}|${filter['plant_id']}';
      return store[key] ?? const [];
    }, clock: const _FakeClock());

    final c = ProviderContainer(
      overrides: [
        communityRepositoryProvider.overrideWithValue(repo),
        communityBucketsProvider.overrideWith((ref) async => buckets),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('widens the geography one level when the finer one is too thin', () async {
    // r7 exists but below kCommunityPrivacyMin (5) → must not be used.
    store['activity_season|r7|cellA|mow|@site'] = _season(3);
    store['activity_season|r6|cellB|mow|@site'] = _season(20);

    final curve = await container().read(
      communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
    );

    expect(curve, isNotNull);
    expect(curve!.bucket, _r6); // never pooled with r7
    expect(curve.pooledTotal, 20);
  });

  test('the cohort is never swapped, only the geography widens', () async {
    // Nothing for apples nearby; the climate bucket has them.
    store['activity_season|climate|e1_t5|prune|apple'] = _season(12);
    // Raspberry pruning is busy in the finest cell — a different act, so it
    // must NOT answer an apple question (§7.4), however tempting the sample.
    store['activity_season|r7|cellA|prune|raspberry'] = _season(80);
    // Same for the legacy pooled row: it is the contaminated superset.
    store['activity_season|r7|cellA|prune|'] = _season(90);

    final curve = await container().read(
      communitySeasonCurveProvider('prune', 'apple').future,
    );

    expect(curve!.bucket, _climate);
    expect(curve.pooledTotal, 12);
  });

  test('no level for this cohort → null, never a blended fallback', () async {
    store['activity_season|r7|cellA|prune|raspberry'] = _season(80);
    store['activity_season|r7|cellA|prune|'] = _season(90);

    expect(
      await container().read(
        communitySeasonCurveProvider('prune', 'apple').future,
      ),
      isNull,
    );
  });

  test('null when no level clears the privacy threshold', () async {
    store['activity_season|r7|cellA|mow|@site'] = _season(2);
    store['activity_season|climate|e1_t5|mow|@site'] = _season(4);

    expect(
      await container().read(
        communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
      ),
      isNull,
    );
  });

  test('frequency resolves down the same hierarchy', () async {
    store['activity_frequency|r7|cellA|mow|@site'] = _frequency(3);
    store['activity_frequency|r5|cellC|mow|@site'] = _frequency(18);

    final stats = await container(
      buckets: const [
        _r7,
        Bucket(resolution: CommunityResolution.r5, key: 'cellC'),
      ],
    ).read(communityFrequencyProvider('mow', kCommunityCohortSite).future);

    expect(stats!.bucket.resolution, CommunityResolution.r5);
    expect(stats.nUsers, 18);
  });

  test('no buckets (no location yet) resolves to null, not an error', () async {
    expect(
      await container(
        buckets: const [],
      ).read(communitySeasonCurveProvider('mow', kCommunityCohortSite).future),
      isNull,
    );
  });
}
