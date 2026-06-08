import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_service.dart';
import '../config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'remote_mappers.dart';
import 'sync_status.dart';

part 'sync_push_service.g.dart';

/// Upserts a batch of rows into one remote table. The seam that isolates the
/// service from Supabase: the real impl hits Postgres, tests record the calls.
typedef RemoteUpsert =
    Future<void> Function(String table, List<Map<String, dynamic>> rows);

/// Pushes locally-changed (`sync_status = pending`) rows to the cloud.
///
/// Caller contract (M6.4 wires the triggers): a session must exist and local
/// rows must already be claimed to the real auth.uid() — otherwise RLS rejects
/// the upsert. The service itself just flushes whatever is pending.
class SyncPushService {
  SyncPushService(this._db, this._upsert);

  final AppDatabase _db;
  final RemoteUpsert _upsert;

  /// Flushes every pending row to the cloud in FK-safe order, then marks the
  /// flushed rows synced. Fail-fast: a table's upsert error aborts the rest
  /// (later tables FK-depend on earlier ones) and leaves their rows pending for
  /// the next trigger. Returns the number of rows pushed.
  Future<int> push() async {
    var n = 0;
    n += await _pushTable(
      _db.profiles,
      () =>
          _pending(_db.profiles, (t) => t.syncStatus, ownerId: (t) => t.userId),
      profileToRemote,
      keyColumn: 'user_id',
      keyOf: (r) => r.userId,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.areas,
      () => _pending(_db.areas, (t) => t.syncStatus, ownerId: (t) => t.userId),
      areaToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.supplies,
      () =>
          _pending(_db.supplies, (t) => t.syncStatus, ownerId: (t) => t.userId),
      supplyToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.recipes,
      () =>
          _pending(_db.recipes, (t) => t.syncStatus, ownerId: (t) => t.userId),
      recipeToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.userPlants,
      () => _pending(
        _db.userPlants,
        (t) => t.syncStatus,
        ownerId: (t) => t.userId,
      ),
      userPlantToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.tasks,
      () => _pending(_db.tasks, (t) => t.syncStatus, ownerId: (t) => t.userId),
      taskToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.notes,
      () => _pending(_db.notes, (t) => t.syncStatus, ownerId: (t) => t.userId),
      noteToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.taskSubjects,
      () => _pending(_db.taskSubjects, (t) => t.syncStatus),
      taskSubjectToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.taskReminders,
      () => _pending(_db.taskReminders, (t) => t.syncStatus),
      taskReminderToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    n += await _pushTable(
      _db.taskSupplies,
      () => _pending(_db.taskSupplies, (t) => t.syncStatus),
      taskSupplyToRemote,
      keyOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    return n;
  }

  Future<List<D>> _pending<T extends Table, D>(
    TableInfo<T, D> table,
    GeneratedColumn<String> Function(T) syncStatus, {
    GeneratedColumn<String> Function(T)? ownerId,
  }) =>
      (_db.select(table)..where((t) {
            final pending = syncStatus(t).equals(kSyncPending);
            // Never push rows still owned by 'local' — it is not a valid uuid
            // (Postgres would reject it) and claimLocalRows re-owns them once
            // a session exists. Child tables (no user_id) rely on that claim.
            if (ownerId == null) return pending;
            return pending & ownerId(t).equals(kLocalUserId).not();
          }))
          .get();

  Future<int> _pushTable<D>(
    TableInfo<Table, dynamic> table,
    Future<List<D>> Function() fetchPending,
    Map<String, dynamic> Function(D) toRemote, {
    String keyColumn = 'id',
    required Object Function(D) keyOf,
    required DateTime Function(D) updatedAtOf,
  }) async {
    final rows = await fetchPending();
    if (rows.isEmpty) return 0;
    await _upsert(table.actualTableName, [for (final r in rows) toRemote(r)]);
    await _markSynced(table, keyColumn, [
      for (final r in rows) (key: keyOf(r), updatedAt: updatedAtOf(r)),
    ]);
    return rows.length;
  }

  /// Flips pushed rows to synced. The `updated_at` guard keeps a row pending if
  /// it was edited between the read and this mark (its newer change must still
  /// flush) — without it that edit would be silently lost from sync.
  Future<void> _markSynced(
    TableInfo<Table, dynamic> table,
    String keyColumn,
    List<({Object key, DateTime updatedAt})> rows,
  ) async {
    await _db.transaction(() async {
      for (final r in rows) {
        await _db.customUpdate(
          'UPDATE ${table.actualTableName} SET sync_status = ? '
          'WHERE $keyColumn = ? AND updated_at = ? AND sync_status = ?',
          variables: [
            const Variable(kSyncSynced),
            Variable(r.key),
            Variable(r.updatedAt),
            const Variable(kSyncPending),
          ],
          updates: {table},
        );
      }
    });
  }
}

@Riverpod(keepAlive: true)
SyncPushService? syncPushService(Ref ref) {
  // Null client = Supabase not configured (offline build) → nothing to push to.
  if (kSupabaseUrl.isEmpty) return null;
  final client = Supabase.instance.client;
  return SyncPushService(
    ref.watch(databaseProvider),
    (table, rows) => client.from(table).upsert(rows),
  );
}
