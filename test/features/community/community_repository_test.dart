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
  String storeKey(String table, Map<String, Object> filter) {
    final base = '$table|${filter['resolution']}|${filter['bucket_key']}';
    final taskTypeId = filter['task_type_id'];
    if (taskTypeId == null) return base;
    return '$base|$taskTypeId|${filter['plant_id'] ?? ''}';
  }

  /// A `task_type_id` list means the bulk slice read: the server answers with
  /// every cohort of those types in the bucket, full rows — so the fake stamps
  /// the identifying columns back on, as PostgREST's `select()` would.
  List<Map<String, dynamic>> bulkSlice(
    String table,
    Map<String, Object> filter,
    List<String> taskTypeIds,
  ) {
    final prefix = '$table|${filter['resolution']}|${filter['bucket_key']}|';
    final out = <Map<String, dynamic>>[];
    for (final entry in store.entries) {
      if (!entry.key.startsWith(prefix)) continue;
      final parts = entry.key.substring(prefix.length).split('|');
      if (!taskTypeIds.contains(parts.first)) continue;
      for (final row in entry.value) {
        out.add({...row, 'task_type_id': parts.first, 'plant_id': parts.last});
      }
    }
    return out;
  }

  Future<List<Map<String, dynamic>>> fetch(
    String table,
    Map<String, Object> filter,
  ) async {
    calls++;
    final taskTypeIds = filter['task_type_id'];
    if (taskTypeIds is List) {
      return bulkSlice(table, filter, taskTypeIds.cast<String>());
    }
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

  test('watchBuckets resolves the scope finest → coarsest, skipping gaps', () async {
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u',
            h3R7: const Value('cellA'),
            // No r6 cell: the ladder must close the gap, not stop at it.
            h3R5: const Value('cellC'),
            climateBucket: const Value('e1_t5'),
            updatedAt: DateTime(2026, 6, 1),
          ),
        );

    expect(await repo().watchBuckets('u').first, const [
      Bucket(resolution: CommunityResolution.r7, key: 'cellA'),
      Bucket(resolution: CommunityResolution.r5, key: 'cellC'),
      Bucket(resolution: CommunityResolution.climate, key: 'e1_t5'),
    ]);
  });

  test('watchBuckets on a device with no profile has no scope at all', () async {
    expect(await repo().watchBuckets('u').first, isEmpty);
  });

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

  test('a write prunes slices nobody can reach any more', () async {
    await repo().feed(buckets: buckets);
    final before = await db.select(db.communityCaches).get();
    expect(before, isNotEmpty);

    // The user moves: the old cell's keys can never be rebuilt or read again,
    // and until now only clearAllData removed them.
    clock._now = DateTime(2026, 6, 1, 9).add(
      kCommunityCacheMaxAge + const Duration(days: 1),
    );
    await repo().feed(buckets: buckets);

    final after = await db.select(db.communityCaches).get();
    expect(
      after.every((c) => c.fetchedAt.isAfter(before.first.fetchedAt)),
      isTrue,
      reason: 'stale rows survived the write: ${after.map((c) => c.key)}',
    );
  });

  test('requestRefresh reaches past the day cache (N19)', () async {
    // One instance for the whole test: the request is repository state, and a
    // fresh repo per call would hide a regression by starting empty.
    final r = repo();
    await r.feed(buckets: buckets);
    expect(calls, 3);

    await r.feed(buckets: buckets);
    expect(calls, 3); // same day, no gesture → cache, as before

    r.requestRefresh();
    await r.feed(buckets: buckets);
    expect(calls, 6); // the gesture went to the network

    // And it does not latch: once refetched, the day cache applies again.
    await r.feed(buckets: buckets);
    expect(calls, 6);
  });

  test('a refresh with no signal keeps the last slice and its date', () async {
    await repo().feed(buckets: buckets);

    // Same cache, offline repository, refresh requested: the rows must survive
    // with their real date — a refresh must never empty the screen (P8).
    final r = repo(online: false);
    r.requestRefresh();
    final feed = await r.feed(buckets: buckets);

    expect(feed, isNotNull);
    expect(feed!.items.first.taskTypeId, 'water');
    expect(feed.fetchedAt, DateTime(2026, 6, 1, 9));
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

  test('a feed dates itself by its stalest slice', () async {
    await repo().feed(buckets: buckets);
    final fresh = await repo().feed(buckets: buckets);
    expect(fresh!.fetchedAt, DateTime(2026, 6, 1, 9));

    // Two days on with no signal: the rows survive, the date moves with them.
    clock._now = DateTime(2026, 6, 3, 9);
    final stale = await repo(online: false).feed(buckets: buckets);
    expect(stale!.fetchedAt, DateTime(2026, 6, 1, 9));
  });

  test('hasCachedScope tells an empty neighbourhood from an unread one', () async {
    // Never reached: the emptiness is a fact about the device.
    expect(await repo(online: false).hasCachedScope(buckets), isFalse);

    await repo().feed(buckets: buckets);

    // Reached once — the answer stays available offline, and so does the right
    // to say "not enough gardeners nearby".
    expect(await repo(online: false).hasCachedScope(buckets), isTrue);
  });

  test('hasCachedScope ignores slices of another scope', () async {
    await repo().feed(buckets: buckets);

    const elsewhere = [
      Bucket(resolution: CommunityResolution.r7, key: 'somewhere-else'),
    ];
    expect(await repo(online: false).hasCachedScope(elsewhere), isFalse);
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

  group('recentActivity — the detail screen "this week" line', () {
    test('reads the cohort out of the slice the feed already cached', () async {
      final before = calls;
      await repo().feed(buckets: buckets); // warms the r6 slice
      final warmed = calls;

      final weekly = await repo().recentActivity(
        bucket: r6,
        taskTypeId: 'prune',
        cohort: 'apple',
      );

      expect(weekly, isNotNull);
      expect(weekly!.intensity, CommunityIntensity.some); // 4/40
      expect(calls, warmed); // same daily slice, no extra request
      expect(warmed, greaterThan(before));
    });

    test('null for a cohort the level does not carry, so the caller widens', () async {
      expect(
        await repo().recentActivity(
          bucket: r6,
          taskTypeId: 'prune',
          cohort: 'pear',
        ),
        isNull,
      );
    });

    test('never answers with the contaminated superset row', () async {
      // 'prune' has a pooled row of 9 users in the slice; asking for the site
      // cohort must not hand it back (it is not site work at all).
      expect(
        await repo().recentActivity(
          bucket: r6,
          taskTypeId: 'prune',
          cohort: kCommunityCohortSite,
        ),
        isNull,
      );
    });
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
    expect(feed.fetchedAt, DateTime(2026, 6, 1, 9)); // dated as yesterday's
  });

  test('a feed is dated by its stalest slice, not its freshest', () async {
    await repo().feed(buckets: buckets); // both slices read on day 1
    clock._now = DateTime(2026, 6, 2, 9);

    // Only the feed slice fails today: the population refreshes, the cohorts
    // stay yesterday's — so the screen must say yesterday.
    final partial = CommunityRepository(db, (table, filter) async {
      if (table == 'activity_recent') throw Exception('network down');
      return fetch(table, filter);
    }, clock: clock);

    final feed = await partial.feed(buckets: buckets);
    expect(feed!.fetchedAt, DateTime(2026, 6, 1, 9));
  });

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

  group('watchMySeasons + seasonCurves (the standings list)', () {
    test('groups every cohort I worked this season, first date and count', () async {
      await addDone('t-site', DateTime(2026, 3, 10, 9));
      await addDone('t-site2', DateTime(2026, 3, 20, 9));
      await addDone('t-apple', DateTime(2026, 2, 5, 9), plantId: 'apple');
      await addDone(
        't-water',
        DateTime(2026, 4, 1, 9),
        taskTypeId: 'water',
        plantId: 'apple',
      );
      await addDone('t-lastyear', DateTime(2025, 3, 1, 9));

      final mine = await repo().watchMySeasons().first;

      expect(mine.keys.toSet(), {
        ('mow', kCommunityCohortSite),
        ('mow', 'apple'),
        ('water', 'apple'),
      });
      expect(mine[('mow', kCommunityCohortSite)]!.count, 2);
      expect(
        mine[('mow', kCommunityCohortSite)]!.first?.toLocal(),
        DateTime(2026, 3, 10, 9),
      );
      expect(mine[('mow', 'apple')]!.count, 1);
    });

    test('one request per level, not one per cohort', () async {
      store['activity_season|r6|cellB|mow|@site'] = const [
        {'year': 2025, 'iso_week': 12, 'first_user_count': 9},
      ];
      store['activity_season|r6|cellB|prune|apple'] = const [
        {'year': 2025, 'iso_week': 10, 'first_user_count': 8},
      ];
      store['activity_season|r6|cellB|water|apple'] = const [
        {'year': 2025, 'iso_week': 20, 'first_user_count': 7},
      ];

      final before = calls;
      final curves = await repo().seasonCurves(
        buckets: buckets,
        pairs: const [
          ('mow', kCommunityCohortSite),
          ('prune', 'apple'),
          ('water', 'apple'),
        ],
      );

      expect(curves.keys.toSet(), {
        ('mow', kCommunityCohortSite),
        ('prune', 'apple'),
        ('water', 'apple'),
      });
      expect(curves[('prune', 'apple')]!.pooledTotal, 8);
      // One slice for r7 (empty) and one for r6 — three cohorts, two requests.
      expect(calls - before, 2);
    });

    test('a bulk slice that hit the row cap is not split into the cache', () async {
      // PostgREST cuts at max_rows with no error, and the cut takes rows we
      // cannot identify. Splitting such a slice per cohort would cache a curve
      // that is quietly missing weeks — and the client re-scales what is left,
      // so every percentage moves while still looking valid.
      store['activity_season|r6|cellB|mow|@site'] = [
        for (var i = 0; i < kCommunityRowLimit; i++)
          {'year': 2025, 'iso_week': (i % 53) + 1, 'first_user_count': 1},
      ];
      store['activity_season|r6|cellB|prune|apple'] = const [
        {'year': 2025, 'iso_week': 10, 'first_user_count': 8},
      ];

      final curves = await repo().seasonCurves(
        buckets: buckets,
        pairs: const [('mow', kCommunityCohortSite), ('prune', 'apple')],
      );

      // The neighbour cohort is unharmed: dropping the bulk slice sends each
      // pair to its own exact read instead of a share of a truncated one.
      expect(curves[('prune', 'apple')]!.pooledTotal, 8);
      // The capped cohort gets no curve at all — silence beats a re-scaled one.
      expect(curves.containsKey(('mow', kCommunityCohortSite)), isFalse);
    });

    test('the list warms the detail: opening one afterwards costs nothing', () async {
      store['activity_season|r6|cellB|prune|apple'] = const [
        {'year': 2025, 'iso_week': 10, 'first_user_count': 8},
      ];
      await repo().seasonCurves(
        buckets: buckets,
        pairs: const [('prune', 'apple')],
      );
      final warmed = calls;

      final curve = await repo().seasonCurve(
        bucket: r6,
        taskTypeId: 'prune',
        cohort: 'apple',
      );

      expect(curve!.pooledTotal, 8);
      expect(calls, warmed); // the bulk read stored it under this very key
    });

    test('a cohort nobody nearby does is left out, not blended', () async {
      store['activity_season|r6|cellB|prune|apple'] = const [
        {'year': 2025, 'iso_week': 10, 'first_user_count': 8},
      ];

      final curves = await repo().seasonCurves(
        buckets: buckets,
        pairs: const [('prune', 'apple'), ('prune', 'pear')],
      );

      expect(curves.keys, [('prune', 'apple')]);
    });

    test('a level that answers stops the widening for that cohort', () async {
      store['activity_season|r7|cellA|mow|@site'] = const [
        {'year': 2025, 'iso_week': 12, 'first_user_count': 6},
      ];
      store['activity_season|r6|cellB|mow|@site'] = const [
        {'year': 2025, 'iso_week': 30, 'first_user_count': 99},
      ];

      final curves = await repo().seasonCurves(
        buckets: buckets,
        pairs: const [('mow', kCommunityCohortSite)],
      );

      // r7 already had enough gardeners, so the coarser r6 never overrides it.
      expect(curves[('mow', kCommunityCohortSite)]!.bucket.resolution,
          CommunityResolution.r7);
      expect(curves[('mow', kCommunityCohortSite)]!.pooledTotal, 6);
    });
  });

  group('watchMySeason (local only)', () {
    Future<MySeason> mySeason(String cohort, {String type = 'mow'}) =>
        repo().watchMySeason(type, cohort: cohort).first;

    test('returns the first date and the count of this calendar season', () async {
      await addDone('t-late', DateTime(2026, 5, 20, 9));
      await addDone('t-first', DateTime(2026, 4, 2, 9));
      await addDone('t-lastyear', DateTime(2025, 3, 1, 9));

      final mine = await mySeason(kCommunityCohortSite);
      expect(mine.first?.toLocal(), DateTime(2026, 4, 2, 9));
      expect(mine.count, 2); // last year is a different season
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
        await mySeason(kCommunityCohortSite),
        const MySeason(first: null, count: 0),
      );
    });

    test('each cohort answers with its own first date', () async {
      await addDone('t-site', DateTime(2026, 3, 10, 9));
      await addDone('t-apple', DateTime(2026, 2, 5, 9), plantId: 'apple');
      await addDone('t-raspberry', DateTime(2026, 8, 5, 9), plantId: 'raspberry');

      expect(
        (await mySeason('apple')).first?.toLocal(),
        DateTime(2026, 2, 5, 9),
      );
      expect(
        (await mySeason('raspberry')).first?.toLocal(),
        DateTime(2026, 8, 5, 9),
      );
      // A task on a plant is NOT site work, so the site cohort ignores it.
      expect(
        (await mySeason(kCommunityCohortSite)).first?.toLocal(),
        DateTime(2026, 3, 10, 9),
      );
      expect((await mySeason('pepper')).count, 0);
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
        (await mySeason(kCommunityCohortSite)).first?.toLocal(),
        DateTime(2026, 4, 1, 9),
      );
    });
  });
}
