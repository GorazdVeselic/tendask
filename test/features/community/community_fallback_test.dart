import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Refreshable;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
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

  /// The season curve is published for seasonal acts only (§7.5), so the
  /// catalog has to be there before any of it resolves.
  Future<void> seedTaskType(String id, {required bool seasonal}) =>
      db.into(db.taskTypes).insert(
        TaskTypesCompanion.insert(
          id: id,
          labels: '{"en":"$id"}',
          icon: '🌱',
          category: 'care',
          seasonal: Value(seasonal),
        ),
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = {};
    await seedTaskType('mow', seasonal: true);
    await seedTaskType('prune', seasonal: true);
    await seedTaskType('water', seasonal: false);
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
        // The seasonal guard reads the catalog through the provider graph, so
        // the in-memory db has to be the one the graph sees too.
        databaseProvider.overrideWithValue(db),
        communityRepositoryProvider.overrideWithValue(repo),
        communityBucketsProvider.overrideWith((ref) => Stream.value(buckets)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Reads an autoDispose provider the way a screen does — subscribed. A bare
  /// `read` lets the scheduler tear the provider down mid-await, and the result
  /// never arrives.
  Future<T> readAlive<T>(ProviderContainer c, Refreshable<Future<T>> p) {
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    return sub.read();
  }

  test('widens the geography one level when the finer one is too thin', () async {
    // r7 exists but below kCommunityPrivacyMin (5) → must not be used.
    store['activity_season|r7|cellA|mow|@site'] = _season(3);
    store['activity_season|r6|cellB|mow|@site'] = _season(20);

    final curve = await readAlive(
      container(),
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

    final curve = await readAlive(
      container(),
      communitySeasonCurveProvider('prune', 'apple').future,
    );

    expect(curve!.bucket, _climate);
    expect(curve.pooledTotal, 12);
  });

  test('no level for this cohort → null, never a blended fallback', () async {
    store['activity_season|r7|cellA|prune|raspberry'] = _season(80);
    store['activity_season|r7|cellA|prune|'] = _season(90);

    expect(
      await readAlive(
        container(),
        communitySeasonCurveProvider('prune', 'apple').future,
      ),
      isNull,
    );
  });

  test('null when no level clears the privacy threshold', () async {
    store['activity_season|r7|cellA|mow|@site'] = _season(2);
    store['activity_season|climate|e1_t5|mow|@site'] = _season(4);

    expect(
      await readAlive(
        container(),
        communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
      ),
      isNull,
    );
  });

  test('one gardener below the privacy threshold widens the scope', () async {
    // Every earlier test sat comfortably on one side of the bound; the bound
    // itself is where an off-by-one hides. (Each case needs its own test: the
    // day cache would otherwise serve the first slice to the second.)
    store['activity_season|r7|cellA|mow|@site'] = _season(kCommunityPrivacyMin - 1);
    store['activity_season|r6|cellB|mow|@site'] = _season(20);

    final curve = await readAlive(
      container(),
      communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
    );
    expect(curve!.bucket, _r6);
  });

  test('exactly at the privacy threshold the finest scope answers', () async {
    store['activity_season|r7|cellA|mow|@site'] = _season(kCommunityPrivacyMin);
    store['activity_season|r6|cellB|mow|@site'] = _season(20);

    final curve = await readAlive(
      container(),
      communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
    );
    expect(curve!.bucket, _r7);
    expect(curve.pooledTotal, kCommunityPrivacyMin);
  });

  test('frequency resolves down the same hierarchy', () async {
    store['activity_frequency|r7|cellA|mow|@site'] = _frequency(3);
    store['activity_frequency|r5|cellC|mow|@site'] = _frequency(18);

    final stats = await readAlive(
      container(
        buckets: const [
          _r7,
          Bucket(resolution: CommunityResolution.r5, key: 'cellC'),
        ],
      ),
      communityFrequencyProvider('mow', kCommunityCohortSite).future,
    );

    expect(stats!.bucket.resolution, CommunityResolution.r5);
    expect(stats.nUsers, 18);
  });

  test('a non-seasonal act has no season curve, however rich the data', () async {
    // §7.5: "when in the season did you first water this year" measures when
    // the gardener joined. The cron stopped materializing these (0018), but a
    // slice from an earlier run must not reach the UI either.
    store['activity_season|r7|cellA|water|@site'] = _season(80);

    expect(
      await readAlive(
        container(),
        communitySeasonCurveProvider('water', kCommunityCohortSite).future,
      ),
      isNull,
    );
  });

  test('frequency is kept for non-seasonal acts — only the curve goes', () async {
    // "How often per season" is a fair question about watering; only the
    // time-percentile is not.
    store['activity_frequency|r7|cellA|water|@site'] = _frequency(40);

    final stats = await readAlive(
      container(),
      communityFrequencyProvider('water', kCommunityCohortSite).future,
    );
    expect(stats!.nUsers, 40);
  });

  test('a slice that hit the row cap is refused, not re-scaled', () async {
    // PostgREST truncates at max_rows silently. The curve is normalised over
    // the rows received, so a cut slice does not leave a gap — it moves every
    // percentage, and the result looks perfectly valid.
    store['activity_season|r7|cellA|mow|@site'] = [
      for (var i = 0; i < kCommunityRowLimit; i++)
        {'year': 2025, 'iso_week': (i % 53) + 1, 'first_user_count': 1},
    ];
    store['activity_season|r6|cellB|mow|@site'] = _season(20);

    final curve = await readAlive(
      container(),
      communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
    );

    expect(curve!.bucket, _r6); // widened past the truncated level
    expect(curve.pooledTotal, 20);
  });

  test('no buckets (no location yet) resolves to null, not an error', () async {
    expect(
      await readAlive(
        container(buckets: const []),
        communitySeasonCurveProvider('mow', kCommunityCohortSite).future,
      ),
      isNull,
    );
  });
}
