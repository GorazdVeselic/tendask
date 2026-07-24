import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/core/sync/reconcile_default_garden.dart';
import 'package:tendask/core/sync/sync_status.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late LocalPrefsRepository prefs;

  const uid = 'uid-1';
  final t0 = DateTime.utc(2026, 6, 16, 8);
  final t1 = DateTime.utc(2026, 6, 16, 9);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = LocalPrefsRepository(db);
  });
  tearDown(() async => db.close());

  Future<void> seedLocalGarden(String id) async {
    await db
        .into(db.areas)
        .insert(
          AreasCompanion.insert(
            id: id,
            userId: kLocalUserId,
            name: 'Vrt',
            type: const Value(AreaType.garden),
            updatedAt: t0,
          ),
        );
    await prefs.setDefaultGardenLocalId(id);
  }

  Future<void> insertProfile({required bool seeded}) => db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(
          userId: uid,
          updatedAt: t0,
          defaultGardenSeeded: Value(seeded),
          syncStatus: const Value(kSyncSynced),
        ),
      );

  Future<Area?> area(String id) =>
      (db.select(db.areas)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<Profile?> profile() =>
      (db.select(db.profiles)..where((p) => p.userId.equals(uid)))
          .getSingleOrNull();

  test('new account: adopts the guest garden and flags the account', () async {
    await seedLocalGarden('g1');
    await insertProfile(seeded: false);

    await reconcileDefaultGarden(db, prefs, uid, clock: _FakeClock(t1));

    final g = await area('g1');
    expect(g, isNotNull);
    expect(g!.userId, uid, reason: 'adopted to the real account');
    expect(g.syncStatus, kSyncPending, reason: 'must push');
    final p = await profile();
    expect(p!.defaultGardenSeeded, isTrue);
    expect(p.syncStatus, kSyncPending);
    expect(await prefs.defaultGardenLocalId(), isNull);
  });

  test('new account without a profile row yet: inserts one flagged', () async {
    await seedLocalGarden('g1');

    await reconcileDefaultGarden(db, prefs, uid, clock: _FakeClock(t1));

    expect((await area('g1'))!.userId, uid);
    expect((await profile())!.defaultGardenSeeded, isTrue);
    expect(await prefs.defaultGardenLocalId(), isNull);
  });

  test('already-seeded account: hard-deletes the duplicate, no tombstone', () async {
    await seedLocalGarden('g1');
    await insertProfile(seeded: true);

    await reconcileDefaultGarden(db, prefs, uid, clock: _FakeClock(t1));

    expect(await area('g1'), isNull, reason: 'gone entirely, never synced');
    expect(await prefs.defaultGardenLocalId(), isNull);
  });

  test('no pending garden: no-op', () async {
    await insertProfile(seeded: false);
    await reconcileDefaultGarden(db, prefs, uid, clock: _FakeClock(t1));
    expect(await profile(), isNotNull);
  });

  test('guest (no session): no-op', () async {
    await seedLocalGarden('g1');
    await reconcileDefaultGarden(db, prefs, kLocalUserId);
    expect((await area('g1'))!.userId, kLocalUserId);
    expect(await prefs.defaultGardenLocalId(), 'g1');
  });

  test('crash-safe: an already-adopted garden is never deleted', () async {
    // Simulate a partial prior run: garden adopted (owner = real, flag set) but
    // the pending id was not yet cleared. A re-run must not treat it as a dup.
    await db
        .into(db.areas)
        .insert(
          AreasCompanion.insert(
            id: 'g1',
            userId: uid,
            name: 'Vrt',
            type: const Value(AreaType.garden),
            updatedAt: t0,
          ),
        );
    await prefs.setDefaultGardenLocalId('g1');
    await insertProfile(seeded: true);

    await reconcileDefaultGarden(db, prefs, uid, clock: _FakeClock(t1));

    expect(await area('g1'), isNotNull, reason: 'kept — already adopted');
    expect(await prefs.defaultGardenLocalId(), isNull);
  });
}
