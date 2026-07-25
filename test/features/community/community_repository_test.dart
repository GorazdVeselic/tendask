import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
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

  // Per-task tables (season/frequency) are keyed by type+plant as well, so a
  // shared cache key between two task types would show up here as a wrong slice.
  String storeKey(String table, Map<String, String> filter) {
    final base = '$table|${filter['resolution']}|${filter['bucket_key']}';
    final taskTypeId = filter['task_type_id'];
    if (taskTypeId == null) return base;
    return '$base|$taskTypeId|${filter['plant_id'] ?? ''}';
  }

  Future<List<Map<String, dynamic>>> fetch(
    String table,
    Map<String, String> filter,
  ) async {
    calls++;
    return store[storeKey(table, filter)] ?? const [];
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
      // The slice carries every cohort: '' (contaminated superset, never shown),
      // '@site' (lawn/bed work) and one row per catalog plant.
      'activity_recent|r6|cellB': const [
        {'task_type_id': 'prune', 'plant_id': '', 'distinct_users_7d': 9},
        {'task_type_id': 'prune', 'plant_id': 'apple', 'distinct_users_7d': 4},
        {'task_type_id': 'prune', 'plant_id': 'raspberry', 'distinct_users_7d': 5},
        {'task_type_id': 'water', 'plant_id': '@site', 'distinct_users_7d': 20},
        {'task_type_id': 'mow', 'plant_id': '@site', 'distinct_users_7d': 15},
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

  test('feed ranks cohorts by distinct users and labels intensity', () async {
    final feed = await repo().feed(buckets: buckets);
    final items = feed!.items;

    // The pooled 'prune' row (9 users) must never appear — only its cohorts.
    expect(items.map((i) => '${i.taskTypeId}/${i.cohort}'), [
      'water/@site',
      'mow/@site',
      'prune/raspberry',
      'prune/apple',
    ]);
    expect(items[0].intensity, CommunityIntensity.often); // 20/40
    expect(items[3].intensity, CommunityIntensity.some); // 4/40
  });

  test('one task type cannot fill the feed with its plants', () async {
    store['activity_recent|r6|cellB'] = const [
      {'task_type_id': 'prune', 'plant_id': 'apple', 'distinct_users_7d': 9},
      {'task_type_id': 'prune', 'plant_id': 'pear', 'distinct_users_7d': 8},
      {'task_type_id': 'prune', 'plant_id': 'rose', 'distinct_users_7d': 7},
      {'task_type_id': 'mow', 'plant_id': '@site', 'distinct_users_7d': 6},
    ];

    final feed = await repo().feed(buckets: buckets);
    expect(feed!.items.map((i) => '${i.taskTypeId}/${i.cohort}'), [
      'prune/apple',
      'prune/pear', // capped at kCommunityFeedMaxPerType
      'mow/@site',
    ]);
  });

  test('feed drops malformed rows instead of throwing', () async {
    store['activity_recent|r6|cellB'] = const [
      {'task_type_id': 'water', 'plant_id': '@site', 'distinct_users_7d': 20},
      {'plant_id': '@site', 'distinct_users_7d': 9}, // no task type
      {'task_type_id': 'mow', 'plant_id': '@site'}, // no count
      {'task_type_id': 'prune', 'distinct_users_7d': 8}, // no cohort
      {'task_type_id': 'sow', 'plant_id': 'pea', 'distinct_users_7d': 8},
    ];

    final feed = await repo().feed(buckets: buckets);
    expect(feed!.items.map((i) => i.taskTypeId), ['water', 'sow']);
    expect(feed.items.last.cohort, 'pea');
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

  test('seasonCurve builds the CDF from the slice for that type+plant', () async {
    store['activity_season|r6|cellB|mow|@site'] = const [
      {'year': 2025, 'iso_week': 12, 'first_user_count': 4},
      {'year': 2025, 'iso_week': 14, 'first_user_count': 6},
    ];

    final curve = await repo().seasonCurve(
      bucket: r6,
      taskTypeId: 'mow',
      cohort: kCommunityCohortSite,
    );
    expect(curve, isNotNull);
    expect(curve!.pooledTotal, 10);
    expect(curve.bucket, r6);
    expect(curve.cdf[11], closeTo(0.4, 1e-9));
  });

  test('seasonCurve is null where the level has no published rows', () async {
    expect(
      await repo().seasonCurve(
        bucket: r7,
        taskTypeId: 'mow',
        cohort: kCommunityCohortSite,
      ),
      isNull,
    );
  });

  test('frequency parses the published season summary', () async {
    store['activity_frequency|r6|cellB|mow|@site'] = const [
      {
        'season_year': 2026,
        'n_users': 40,
        'per_user_p25': 2,
        'per_user_p50': 3,
        'per_user_p75': 4,
        'unit': 'per_month',
        'hist': {'1': 4, '3': 12},
      },
    ];

    final stats = await repo().frequency(
      bucket: r6,
      taskTypeId: 'mow',
      cohort: kCommunityCohortSite,
    );
    expect(stats!.nUsers, 40);
    expect(stats.p75, 4);
    expect(stats.hist['3'], 12);
  });

  test('a cohort never answers with another cohort slice', () async {
    store['activity_season|r6|cellB|prune|apple'] = const [
      {'year': 2025, 'iso_week': 10, 'first_user_count': 8},
    ];
    store['activity_season|r6|cellB|prune|raspberry'] = const [
      {'year': 2025, 'iso_week': 32, 'first_user_count': 5},
    ];

    final apple = await repo().seasonCurve(
      bucket: r6,
      taskTypeId: 'prune',
      cohort: 'apple',
    );
    final raspberry = await repo().seasonCurve(
      bucket: r6,
      taskTypeId: 'prune',
      cohort: 'raspberry',
    );
    // Pruning an apple in week 10 and a raspberry in week 32 are different acts:
    // separate curves, never one blended total (§7.4).
    expect(apple!.pooledTotal, 8);
    expect(apple.cdf[9], closeTo(1.0, 1e-9));
    expect(raspberry!.pooledTotal, 5);
    expect(raspberry.cdf[9], 0);
    // And the site cohort of the same type stays empty here.
    expect(
      await repo().seasonCurve(
        bucket: r6,
        taskTypeId: 'prune',
        cohort: kCommunityCohortSite,
      ),
      isNull,
    );
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

  group('myFirstThisSeason (local only)', () {
    /// Inserts a completed task, optionally on a user plant of [plantId].
    Future<void> addDone(
      String id,
      DateTime localDate, {
      String taskTypeId = 'mow',
      String plantId = '',
      TaskStatus status = TaskStatus.done,
    }) async {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: id,
              userId: 'u1',
              taskTypeId: taskTypeId,
              date: localDate.toUtc(),
              status: Value(status),
              updatedAt: localDate.toUtc(),
            ),
          );
      if (plantId.isEmpty) return;
      final userPlantId = 'up-$plantId';
      await db
          .into(db.userPlants)
          .insert(
            UserPlantsCompanion.insert(
              id: userPlantId,
              userId: 'u1',
              plantId: Value(plantId),
              updatedAt: localDate.toUtc(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      await db
          .into(db.taskSubjects)
          .insert(
            TaskSubjectsCompanion.insert(
              id: 'sub-$id',
              taskId: id,
              userPlantId: Value(userPlantId),
              updatedAt: localDate.toUtc(),
            ),
          );
    }

    test('returns the earliest site completion of this calendar season', () async {
      await addDone('t-late', DateTime(2026, 5, 20, 9));
      await addDone('t-first', DateTime(2026, 4, 2, 9));
      await addDone('t-lastyear', DateTime(2025, 3, 1, 9));

      final first = await repo().myFirstThisSeason(
        'mow',
        cohort: kCommunityCohortSite,
      );
      expect(first?.toLocal(), DateTime(2026, 4, 2, 9));
    });

    test('ignores other task types, other years and unfinished tasks', () async {
      await addDone('t-other-type', DateTime(2026, 3, 1, 9), taskTypeId: 'water');
      await addDone('t-lastyear', DateTime(2025, 4, 2, 9));
      await addDone(
        't-waiting',
        DateTime(2026, 2, 1, 9),
        status: TaskStatus.waiting,
      );

      expect(
        await repo().myFirstThisSeason('mow', cohort: kCommunityCohortSite),
        isNull,
      );
    });

    test('each cohort answers with its own first date', () async {
      await addDone('t-site', DateTime(2026, 3, 10, 9));
      await addDone('t-apple', DateTime(2026, 2, 5, 9), plantId: 'apple');
      await addDone('t-raspberry', DateTime(2026, 8, 5, 9), plantId: 'raspberry');

      expect(
        (await repo().myFirstThisSeason('mow', cohort: 'apple'))?.toLocal(),
        DateTime(2026, 2, 5, 9),
      );
      expect(
        (await repo().myFirstThisSeason('mow', cohort: 'raspberry'))?.toLocal(),
        DateTime(2026, 8, 5, 9),
      );
      // A task on a plant is NOT site work, so the site cohort ignores it.
      expect(
        (await repo().myFirstThisSeason(
          'mow',
          cohort: kCommunityCohortSite,
        ))?.toLocal(),
        DateTime(2026, 3, 10, 9),
      );
      expect(await repo().myFirstThisSeason('mow', cohort: 'pepper'), isNull);
    });

    test('a private custom plant counts as site work, like agg_event', () async {
      await db
          .into(db.userPlants)
          .insert(
            UserPlantsCompanion.insert(
              id: 'up-custom',
              userId: 'u1',
              customName: const Value('Babičina vrtnica'),
              isCustom: const Value(true),
              updatedAt: DateTime(2026, 4, 1).toUtc(),
            ),
          );
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: 't-custom',
              userId: 'u1',
              taskTypeId: 'mow',
              date: DateTime(2026, 4, 1, 9).toUtc(),
              status: const Value(TaskStatus.done),
              updatedAt: DateTime(2026, 4, 1, 9).toUtc(),
            ),
          );
      await db
          .into(db.taskSubjects)
          .insert(
            TaskSubjectsCompanion.insert(
              id: 'sub-custom',
              taskId: 't-custom',
              userPlantId: const Value('up-custom'),
              updatedAt: DateTime(2026, 4, 1, 9).toUtc(),
            ),
          );

      expect(
        (await repo().myFirstThisSeason(
          'mow',
          cohort: kCommunityCohortSite,
        ))?.toLocal(),
        DateTime(2026, 4, 1, 9),
      );
    });
  });
}
