import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/sync_push_service.dart';
import 'package:tendask/core/sync/sync_status.dart';

/// Records every upsert; can fail on a given table or run a side effect per call
/// (used to simulate a concurrent edit landing mid-push).
class _FakeUpsert {
  final calls = <String>[];
  String? failOn;
  Future<void> Function(String table)? onCall;

  Future<void> call(String table, List<Map<String, dynamic>> rows) async {
    calls.add(table);
    if (onCall != null) await onCall!(table);
    if (table == failOn) throw Exception('network down');
  }
}

void main() {
  late AppDatabase db;
  late _FakeUpsert upsert;
  late SyncPushService service;
  final t0 = DateTime.utc(2026, 6, 5, 10);
  final t1 = DateTime.utc(2026, 6, 5, 11);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    upsert = _FakeUpsert();
    service = SyncPushService(db, upsert.call);
  });
  tearDown(() async => db.close());

  Future<void> insertProfile(String userId, {DateTime? at, String? sync}) => db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(
          userId: userId,
          updatedAt: at ?? t0,
          syncStatus: sync == null ? const Value.absent() : Value(sync),
        ),
      );

  Future<void> insertArea(String id, {DateTime? at, String? sync}) => db
      .into(db.areas)
      .insert(
        AreasCompanion.insert(
          id: id,
          userId: 'u1',
          name: id,
          updatedAt: at ?? t0,
          syncStatus: sync == null ? const Value.absent() : Value(sync),
        ),
      );

  Future<void> insertTask(String id, {String? sync}) => db
      .into(db.tasks)
      .insert(
        TasksCompanion.insert(
          id: id,
          userId: 'u1',
          taskTypeId: 'water',
          date: t0,
          updatedAt: t0,
          syncStatus: sync == null ? const Value.absent() : Value(sync),
        ),
      );

  Future<Area> area(String id) =>
      (db.select(db.areas)..where((a) => a.id.equals(id))).getSingle();
  Future<Task> task(String id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();

  test('pushes only pending rows, in FK-safe order', () async {
    await insertProfile('u1');
    await insertArea('a1');
    await insertArea('a2', sync: kSyncSynced); // already synced → skipped
    await insertTask('t1');

    final n = await service.push();

    expect(n, 3);
    // profile before area before task; synced a2 never upserted.
    expect(upsert.calls, ['profile', 'area', 'task']);
  });

  test(
    'flips pushed rows to synced; untouched rows keep their status',
    () async {
      await insertArea('a1');
      await insertArea('a2', sync: kSyncSynced);

      await service.push();

      expect((await area('a1')).syncStatus, kSyncSynced);
      expect((await area('a2')).syncStatus, kSyncSynced);
    },
  );

  test('skips upsert entirely when nothing is pending', () async {
    await insertArea('a1', sync: kSyncSynced);
    final n = await service.push();
    expect(n, 0);
    expect(upsert.calls, isEmpty);
  });

  test('a row edited mid-push stays pending (updated_at guard)', () async {
    await insertArea('a1');
    // The cloud upsert "succeeds", but a concurrent edit bumps a1 meanwhile.
    upsert.onCall = (table) async {
      if (table == 'area') {
        await (db.update(db.areas)..where((a) => a.id.equals('a1'))).write(
          AreasCompanion(
            updatedAt: Value(t1),
            syncStatus: const Value(kSyncPending),
          ),
        );
      }
    };

    await service.push();

    final a1 = await area('a1');
    expect(a1.updatedAt.isAtSameMomentAs(t1), isTrue);
    expect(a1.syncStatus, kSyncPending); // newer change must still flush later
  });

  test(
    'never pushes device_location — raw coordinates stay on the device',
    () async {
      // Privacy by design (CLAUDE.md §2): only derived H3 cells (in profile) sync;
      // the raw lat/lon in device_location must never reach the cloud.
      await db
          .into(db.deviceLocations)
          .insert(
            DeviceLocationsCompanion.insert(
              latitude: 46.05,
              longitude: 14.5,
              updatedAt: t0,
            ),
          );
      await insertArea('a1'); // a pending owned row so the push actually runs

      await service.push();

      expect(upsert.calls, isNot(contains('device_location')));
      expect(upsert.calls, ['area']); // only the owned table, never coordinates
    },
  );

  test(
    'fail-fast: a failing table aborts the rest, leaving them pending',
    () async {
      await insertArea('a1');
      await insertTask('t1');
      upsert.failOn = 'task';

      await expectLater(service.push(), throwsException);

      // area pushed before the failure → synced; task never marked.
      expect((await area('a1')).syncStatus, kSyncSynced);
      expect((await task('t1')).syncStatus, kSyncPending);
    },
  );
}
