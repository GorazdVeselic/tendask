import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/auth/local_row_claim.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/sync_status.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime.utc(2026, 6, 4, 10);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> insertArea(String id, String userId, {String? sync}) =>
      db.into(db.areas).insert(AreasCompanion.insert(
            id: id,
            userId: userId,
            name: 'A',
            updatedAt: t0,
            syncStatus: sync == null ? const Value.absent() : Value(sync),
          ));

  Future<Area> area(String id) =>
      (db.select(db.areas)..where((a) => a.id.equals(id))).getSingle();

  test('is a no-op while still local (no session yet)', () async {
    await insertArea('a1', kLocalUserId);
    await claimLocalRows(db, kLocalUserId);
    expect((await area('a1')).userId, kLocalUserId);
  });

  test('claims local rows to the real uid and marks them pending', () async {
    // Pre-set synced to prove claim flips it back to pending.
    await insertArea('a1', kLocalUserId, sync: kSyncSynced);
    await claimLocalRows(db, 'uid-1');
    final a1 = await area('a1');
    expect(a1.userId, 'uid-1');
    expect(a1.syncStatus, kSyncPending);
  });

  test('claims across every owned table at once', () async {
    await insertArea('a1', kLocalUserId);
    await db.into(db.supplies).insert(SuppliesCompanion.insert(
        id: 's1', userId: kLocalUserId, name: 'S', updatedAt: t0));
    await db.into(db.tasks).insert(TasksCompanion.insert(
        id: 't1',
        userId: kLocalUserId,
        taskTypeId: 'water',
        date: t0,
        updatedAt: t0));

    await claimLocalRows(db, 'uid-1');

    expect((await area('a1')).userId, 'uid-1');
    final s1 = await (db.select(db.supplies)..where((s) => s.id.equals('s1')))
        .getSingle();
    expect(s1.userId, 'uid-1');
    final t1 =
        await (db.select(db.tasks)..where((t) => t.id.equals('t1'))).getSingle();
    expect(t1.userId, 'uid-1');
  });

  test('leaves rows owned by another user untouched', () async {
    await insertArea('a1', kLocalUserId);
    await insertArea('a2', 'uid-other', sync: kSyncSynced);
    await claimLocalRows(db, 'uid-1');
    final a2 = await area('a2');
    expect(a2.userId, 'uid-other');
    expect(a2.syncStatus, kSyncSynced);
  });
}
