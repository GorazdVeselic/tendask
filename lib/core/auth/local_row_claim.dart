import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../sync/sync_status.dart';
import 'auth_service.dart';

/// Re-owns rows created offline (user_id == [kLocalUserId]) to the real
/// [userId] once a session exists — without this the cloud RLS with-check
/// rejects them on push. Marks them pending so the next push flushes them;
/// updated_at is left untouched (claiming is not a content edit). No-op while
/// still local. Child tables (task_subject/_reminder/_supply) carry no user_id —
/// ownership flows through their parent task.
///
/// [skipAreaId] is the locally-seeded default garden still awaiting reconcile:
/// it must stay owned by `local` (so push never uploads it) until the post-pull
/// reconcile decides to adopt or drop it. Any other guest area is claimed.
Future<void> claimLocalRows(
  AppDatabase db,
  String userId, {
  String? skipAreaId,
}) async {
  if (userId == kLocalUserId) return;
  final owned = <TableInfo<Table, dynamic>>[
    db.profiles,
    db.areas,
    db.userPlants,
    db.tasks,
    db.notes,
    db.supplies,
    db.recipes,
  ];
  await db.transaction(() async {
    for (final table in owned) {
      final skip = table == db.areas && skipAreaId != null;
      await db.customUpdate(
        'UPDATE ${table.actualTableName} SET user_id = ?, sync_status = ? '
        'WHERE user_id = ?${skip ? ' AND id != ?' : ''}',
        variables: [
          Variable(userId),
          const Variable(kSyncPending),
          const Variable(kLocalUserId),
          if (skip) Variable(skipAreaId),
        ],
        updates: {table},
      );
    }
  });
}
