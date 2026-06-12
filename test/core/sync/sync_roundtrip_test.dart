import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/suggestion_status.dart';
import 'package:tendask/core/sync/sync_pull_service.dart';
import 'package:tendask/core/sync/sync_push_service.dart';
import 'package:tendask/core/sync/sync_status.dart';
import 'package:tendask/core/task_status.dart';

/// In-memory stand-in for the cloud that serves BOTH sync seams: [upsert]
/// (push target) and [fetch] (pull source) over one shared store. Pushing then
/// pulling therefore round-trips through the real `*ToRemote`/`*FromRemote`
/// mappers — the gap the per-service tests (canned data on each side) leave open.
class _FakeCloud {
  final Map<String, List<Map<String, dynamic>>> store = {};

  String _pk(String table) => table == 'profile' ? 'user_id' : 'id';

  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    final list = store.putIfAbsent(table, () => []);
    final pk = _pk(table);
    for (final row in rows) {
      list.removeWhere((r) => r[pk] == row[pk]);
      list.add(Map<String, dynamic>.from(row));
    }
  }

  Future<List<Map<String, dynamic>>> fetch(
    String table, {
    required String sinceIso,
    String? userId,
  }) async {
    final list = store[table] ?? const [];
    return [
      for (final r in list)
        // Mirrors Postgres `updated_at >= since` (+ owner filter); ISO-8601 UTC
        // strings compare lexicographically, same as chronologically.
        if ((r['updated_at'] as String).compareTo(sinceIso) >= 0 &&
            (userId == null || r['user_id'] == userId))
          Map<String, dynamic>.from(r),
    ];
  }
}

void main() {
  late AppDatabase dbA, dbB;
  late _FakeCloud cloud;
  late SyncPushService pushA, pushB;
  late SyncPullService pullA, pullB;
  const uid = 'u1';
  final t1 = DateTime.utc(2026, 6, 5, 10);
  final t2 = DateTime.utc(2026, 6, 5, 12);

  setUp(() {
    dbA = AppDatabase.forTesting(NativeDatabase.memory());
    dbB = AppDatabase.forTesting(NativeDatabase.memory());
    cloud = _FakeCloud();
    pushA = SyncPushService(dbA, cloud.upsert);
    pushB = SyncPushService(dbB, cloud.upsert);
    pullA = SyncPullService(dbA, cloud.fetch, () => uid);
    pullB = SyncPullService(dbB, cloud.fetch, () => uid);
  });
  tearDown(() async {
    await dbA.close();
    await dbB.close();
  });

  Future<void> putArea(
    AppDatabase db,
    String id, {
    required String name,
    required DateTime at,
    AreaType type = AreaType.bed,
    bool protected = true,
    bool deleted = false,
    String sync = kSyncPending,
  }) => db
      .into(db.areas)
      .insertOnConflictUpdate(
        AreasCompanion.insert(
          id: id,
          userId: uid,
          name: name,
          updatedAt: at,
          type: Value(type),
          protected: Value(protected),
          deleted: Value(deleted),
          syncStatus: Value(sync),
        ),
      );

  Future<Area?> area(AppDatabase db, String id) =>
      (db.select(db.areas)..where((a) => a.id.equals(id))).getSingleOrNull();
  Future<Task?> task(AppDatabase db, String id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  test(
    'an area pushed by one device pulls into another, fields intact',
    () async {
      await putArea(dbA, 'a1', name: 'Sadovnjak', at: t1, type: AreaType.tree);

      await pushA.push();
      final pulled = await pullB.pull();

      expect(pulled, 1);
      final b = await area(dbB, 'a1');
      expect(b, isNotNull);
      expect(b!.name, 'Sadovnjak');
      expect(b.type, AreaType.tree); // enum round-tripped via name
      expect(b.protected, isTrue);
      expect(b.syncStatus, kSyncSynced);
      // The source device's row is flipped to synced by the push.
      expect((await area(dbA, 'a1'))!.syncStatus, kSyncSynced);
    },
  );

  test(
    'owned tables round-trip together: task enum status + jsonb weather',
    () async {
      await putArea(dbA, 'a1', name: 'Greda', at: t1);
      await dbA
          .into(dbA.tasks)
          .insert(
            TasksCompanion.insert(
              id: 't1',
              userId: uid,
              taskTypeId: 'water',
              date: t1,
              updatedAt: t1,
              status: const Value(TaskStatus.done),
              weather: const Value('{"temp":18.5,"wind":3}'),
              syncStatus: const Value(kSyncPending),
            ),
          );

      await pushA.push();
      await pullB.pull();

      final t = await task(dbB, 't1');
      expect(t, isNotNull);
      expect(t!.status, TaskStatus.done); // textEnum round-tripped via name
      expect(jsonDecode(t.weather!), {
        'temp': 18.5,
        'wind': 3,
      }); // jsonb round-tripped
      expect(t.syncStatus, kSyncSynced);
      // The area (a separate owned table) pulled in the same cycle.
      expect(await area(dbB, 'a1'), isNotNull);
    },
  );

  test(
    'LWW across two devices: a newer remote edit overwrites the older local',
    () async {
      await putArea(dbA, 'a1', name: 'Orig', at: t1);
      await pushA.push();
      await pullB.pull(); // B now has a1@t1, synced

      // B edits and pushes a newer version.
      await putArea(dbB, 'a1', name: 'Edited', at: t2);
      await pushB.push();

      // A still holds the older synced a1; pulling resolves LWW in B's favour.
      final n = await pullA.pull();
      expect(n, 1);
      final a = await area(dbA, 'a1');
      expect(a!.name, 'Edited');
      expect(a.syncStatus, kSyncSynced);
    },
  );

  test(
    'suggestion: server-authored row pulls in, a status flip pushes back',
    () async {
      // The engine (server) authored a suggestion in the cloud.
      cloud.store['suggestion'] = [
        {
          'id': 's1',
          'user_id': uid,
          'rule_id': 'R5',
          'plant_task_rule_id': 'apple.prune.winter',
          'task_type_id': 'prune',
          'user_plant_id': null,
          'area_id': null,
          'subject_key': 'cat:fruit_tree',
          'message_key': 'suggestions.prune_window',
          'message_params': {'plant': 'apple'},
          'score': 2.5,
          'status': 'new',
          'dismiss_scope': 'season',
          'planned_task_id': null,
          'valid_until': '2026-07-01',
          'created_at': t1.toIso8601String(),
          'updated_at': t1.toIso8601String(),
          'deleted': false,
        },
      ];

      await pullA.pull();
      final pulledRow = await dbA.select(dbA.suggestions).getSingle();
      expect(pulledRow.status, kSuggestionNew);
      expect(jsonDecode(pulledRow.messageParams), {'plant': 'apple'});
      // Server-authored → synced; the pull must not create pending noise.
      expect(pulledRow.syncStatus, kSyncSynced);

      // The user plans it → only that change goes pending and pushes back.
      await (dbA.update(dbA.suggestions)..where((s) => s.id.equals('s1')))
          .write(
            SuggestionsCompanion(
              status: const Value(kSuggestionPlanned),
              updatedAt: Value(t2),
              syncStatus: const Value(kSyncPending),
            ),
          );
      final pushed = await pushA.push();
      expect(pushed, 1);
      expect(cloud.store['suggestion']!.single['status'], kSuggestionPlanned);

      // A second device picks the change up on pull.
      await pullB.pull();
      final b = await dbB.select(dbB.suggestions).getSingle();
      expect(b.status, kSuggestionPlanned);
    },
  );

  test('suggestion_log mirrors in as pull-only guard state', () async {
    cloud.store['suggestion_log'] = [
      {
        'user_id': uid,
        'guard_key': 'R5:prune',
        'subject_key': 'cat:fruit_tree',
        'last_suggested_at': t1.toIso8601String(),
        'dismissed_until': null,
        'updated_at': t1.toIso8601String(),
      },
    ];

    await pullA.pull();
    final log = await dbA.select(dbA.suggestionLogs).getSingle();
    expect(log.guardKey, 'R5:prune');
    expect(log.lastSuggestedAt, isNotNull);
    expect(log.dismissedUntil, isNull);

    // Nothing to push back — the table has no syncStatus column at all.
    expect(await pushA.push(), 0);
  });

  test('a soft delete propagates as a tombstone to the other device', () async {
    await putArea(dbA, 'a1', name: 'Doomed', at: t1);
    await pushA.push();
    await pullB.pull();

    // B soft-deletes and pushes the tombstone.
    await putArea(dbB, 'a1', name: 'Doomed', at: t2, deleted: true);
    await pushB.push();

    await pullA.pull();
    final a = await area(dbA, 'a1');
    expect(a, isNotNull); // not hard-deleted...
    expect(a!.deleted, isTrue); // ...mirrored as a soft delete
  });
}
