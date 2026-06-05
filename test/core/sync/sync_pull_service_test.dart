import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/sync_pull_service.dart';
import 'package:tendask/core/sync/sync_status.dart';

/// Returns canned cloud rows per table and records how it was queried.
class _FakeFetch {
  final Map<String, List<Map<String, dynamic>>> byTable = {};
  final calls = <({String table, String since, String? userId})>[];

  Future<List<Map<String, dynamic>>> call(
    String table, {
    required String sinceIso,
    String? userId,
  }) async {
    calls.add((table: table, since: sinceIso, userId: userId));
    return byTable[table] ?? const [];
  }
}

void main() {
  late AppDatabase db;
  late _FakeFetch fetch;
  late SyncPullService service;
  var uid = 'u1';
  final t1 = DateTime.utc(2026, 6, 5, 10);
  final t2 = DateTime.utc(2026, 6, 5, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fetch = _FakeFetch();
    uid = 'u1';
    service = SyncPullService(db, fetch.call, () => uid);
  });
  tearDown(() async => db.close());

  Map<String, dynamic> areaRow(String id,
          {String name = 'Cloud', DateTime? at, bool deleted = false}) =>
      {
        'id': id,
        'user_id': 'u1',
        'name': name,
        'type': 'bed',
        'protected': false,
        'updated_at': (at ?? t1).toIso8601String(),
        'deleted': deleted,
      };

  Future<Area?> area(String id) =>
      (db.select(db.areas)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> insertLocalArea(String id,
          {required String name, required DateTime at, required String sync}) =>
      db.into(db.areas).insert(AreasCompanion.insert(
            id: id,
            userId: 'u1',
            name: name,
            updatedAt: at,
            syncStatus: Value(sync),
          ));

  test('inserts new cloud rows, stamps synced, advances the cursor', () async {
    fetch.byTable['area'] = [areaRow('a1', at: t1)];

    final n = await service.pull();

    expect(n, 1);
    final a1 = await area('a1');
    expect(a1!.name, 'Cloud');
    expect(a1.syncStatus, kSyncSynced);
    final cursor = await db.select(db.syncCursors).getSingle();
    expect(cursor.lastPulledAt.isAtSameMomentAs(t1), isTrue);
  });

  test('no session → no-op (nothing fetched)', () async {
    uid = kLocalUserId;
    final n = await service.pull();
    expect(n, 0);
    expect(fetch.calls, isEmpty);
  });

  test('LWW: a newer local pending edit is kept', () async {
    await insertLocalArea('a1', name: 'Local', at: t2, sync: kSyncPending);
    fetch.byTable['area'] = [areaRow('a1', name: 'Cloud', at: t1)]; // older

    await service.pull();

    final a1 = await area('a1');
    expect(a1!.name, 'Local');
    expect(a1.syncStatus, kSyncPending); // still needs to flush
  });

  test('LWW: a newer cloud row overwrites the local one', () async {
    await insertLocalArea('a1', name: 'Local', at: t1, sync: kSyncPending);
    fetch.byTable['area'] = [areaRow('a1', name: 'Cloud', at: t2)]; // newer

    await service.pull();

    final a1 = await area('a1');
    expect(a1!.name, 'Cloud');
    expect(a1.syncStatus, kSyncSynced);
  });

  test('a cloud tombstone is mirrored as a local soft delete', () async {
    fetch.byTable['area'] = [areaRow('a1', at: t1, deleted: true)];

    await service.pull();

    final a1 = await area('a1');
    expect(a1!.deleted, isTrue);
  });

  test('owned tables filter by user_id; child tables rely on RLS', () async {
    await service.pull();

    final areaCall = fetch.calls.firstWhere((c) => c.table == 'area');
    final subjectCall =
        fetch.calls.firstWhere((c) => c.table == 'task_subject');
    expect(areaCall.userId, 'u1');
    expect(subjectCall.userId, isNull);
  });

  test('cursor makes the next pull incremental (inclusive since)', () async {
    fetch.byTable['area'] = [areaRow('a1', at: t1)];
    await service.pull(); // advances cursor to t1

    fetch.calls.clear();
    fetch.byTable['area'] = const []; // nothing new
    await service.pull();

    final areaCall = fetch.calls.firstWhere((c) => c.table == 'area');
    expect(areaCall.since, t1.toIso8601String());
  });
}
