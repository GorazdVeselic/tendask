import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late int calls;
  // key: '<table>|<resolution>|<bucket_key>' → rows the "server" returns.
  late Map<String, List<Map<String, dynamic>>> store;

  const r7 = Bucket(resolution: CommunityResolution.r7, key: 'cellA');
  const r6 = Bucket(resolution: CommunityResolution.r6, key: 'cellB');
  const climate = Bucket(resolution: CommunityResolution.climate, key: 'e1_t5');
  const buckets = [r7, r6, climate];

  Future<List<Map<String, dynamic>>> fetch(
    String table,
    Map<String, String> filter,
  ) async {
    calls++;
    return store['$table|${filter['resolution']}|${filter['bucket_key']}'] ??
        const [];
  }

  CommunityRepository repo({bool online = true}) =>
      CommunityRepository(db, online ? fetch : null, clock: clock);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = _FakeClock(DateTime(2026, 6, 1, 9));
    calls = 0;
    store = {
      // r7 is hidden by RLS (below k_privacy) → server returns no row.
      'bucket_population|r7|cellA': const [],
      'bucket_population|r6|cellB': const [
        {'distinct_users': 40},
      ],
      'activity_recent|r6|cellB': const [
        {'task_type_id': 'prune', 'plant_id': '', 'distinct_users_7d': 4},
        {'task_type_id': 'water', 'plant_id': '', 'distinct_users_7d': 20},
        {'task_type_id': 'mow', 'plant_id': '', 'distinct_users_7d': 15},
      ],
    };
  });

  tearDown(() => db.close());

  test('feedIntensity maps share of bucket to a qualitative label', () {
    expect(feedIntensity(20, 40), CommunityIntensity.often); // 0.50
    expect(feedIntensity(15, 40), CommunityIntensity.often); // 0.375
    expect(feedIntensity(6, 40), CommunityIntensity.some); // 0.15
    expect(feedIntensity(4, 40), CommunityIntensity.some); // 0.10 (boundary)
    expect(feedIntensity(3, 40), CommunityIntensity.rare); // 0.075
    expect(feedIntensity(1, 0), CommunityIntensity.rare); // guard
  });

  test('feed resolves to the finest bucket above the privacy threshold', () async {
    final feed = await repo().feed(buckets: buckets);
    expect(feed, isNotNull);
    // r7 hidden → widens to r6, never mixing levels.
    expect(feed!.bucket.resolution, CommunityResolution.r6);
    expect(feed.population, 40);
  });

  test('feed ranks items by distinct users and labels intensity', () async {
    final feed = await repo().feed(buckets: buckets);
    final items = feed!.items;
    expect(items.map((i) => i.taskTypeId), ['water', 'mow', 'prune']);
    expect(items[0].intensity, CommunityIntensity.often); // 20/40
    expect(items[2].intensity, CommunityIntensity.some); // 4/40
  });

  test('feed returns null when no bucket clears the threshold', () async {
    store = {'bucket_population|r7|cellA': const []}; // everything hidden
    expect(await repo().feed(buckets: buckets), isNull);
  });

  test('bucketPopulation is null when the RLS row is hidden', () async {
    expect(await repo().bucketPopulation(bucket: r7), isNull);
    expect(await repo().bucketPopulation(bucket: r6), 40);
  });

  test('a slice is fetched at most once per local day', () async {
    await repo().feed(buckets: buckets);
    // pop(r7) + pop(r6) + feed(r6) = 3 network calls the first time.
    expect(calls, 3);

    await repo().feed(buckets: buckets);
    expect(calls, 3); // same day → all served from cache

    clock._now = DateTime(2026, 6, 2, 9); // next day
    await repo().feed(buckets: buckets);
    expect(calls, 6); // re-fetched
  });

  test('offline serves the last cached slice (graceful degrade)', () async {
    await repo().feed(buckets: buckets); // populate cache while online
    final before = calls;

    final feed = await repo(online: false).feed(buckets: buckets);
    expect(feed, isNotNull);
    expect(feed!.bucket.resolution, CommunityResolution.r6);
    expect(feed.items.first.taskTypeId, 'water');
    expect(calls, before); // no network touched
  });

  test('a mid-fetch failure falls back to the stale slice', () async {
    await repo().feed(buckets: buckets); // warm cache
    clock._now = DateTime(2026, 6, 2, 9); // force staleness

    final throwing = CommunityRepository(db, (table, filter) async {
      throw Exception('network down');
    }, clock: clock);
    final feed = await throwing.feed(buckets: buckets);
    expect(feed, isNotNull); // yesterday's slice, not an exception
    expect(feed!.population, 40);
  });
}
