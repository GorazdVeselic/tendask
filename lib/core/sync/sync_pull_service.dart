import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_service.dart';
import '../config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'remote_mappers.dart';

part 'sync_pull_service.g.dart';

/// Fetches cloud rows of one table changed since [sinceIso]. The seam that
/// isolates the service from Supabase: the real impl queries Postgres, tests
/// return canned rows. [userId] non-null → owner-filter; null = child table
/// (RLS scopes it via the parent task).
typedef RemoteFetch =
    Future<List<Map<String, dynamic>>> Function(
      String table, {
      required String sinceIso,
      String? userId,
    });

/// One global pull cursor row. Per-table cursors could slot in later.
const _cursorName = 'pull';

/// Pulls cloud changes into drift incrementally (`updated_at >= last_pulled_at`).
///
/// Correctness guarantees:
///   * **Inclusive cursor + idempotent upsert** — drift stores updated_at at
///     second precision, so a strict `>` would skip rows sharing the cursor's
///     second. We use `>=` and an upsert keyed by id; re-fetched boundary rows
///     are written identically, never lost.
///   * **LWW guard** — a pulled row overwrites the local one only if local is
///     already synced OR not newer. A locally-pending edit that is newer than
///     the cloud row is kept (it must still flush on the next push).
///   * **Tombstones mirrored, not hard-deleted** — `deleted = true` is applied
///     as a soft delete locally (the UI filters it), avoiding local FK-cascade
///     ordering. The pull writes in parent→child order regardless.
class SyncPullService {
  SyncPullService(this._db, this._fetch, this._currentUserId);

  final AppDatabase _db;
  final RemoteFetch _fetch;
  final String Function() _currentUserId;

  /// Pulls every owned table since the cursor, then advances the cursor to the
  /// newest updated_at seen. No-op without a session (nothing to scope to).
  /// Returns the number of rows applied.
  Future<int> pull() async {
    if (_currentUserId() == kLocalUserId) return 0;
    final uid = _currentUserId();
    final cursor = await _readCursor();
    final since = cursor.toUtc().toIso8601String();

    var total = 0;
    var maxTs = cursor;
    // Parent→child so a child's FK target exists locally before it lands.
    for (final r in [
      await _pull(
        _db.profiles,
        userId: uid,
        since: since,
        profileFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.areas,
        userId: uid,
        since: since,
        areaFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.supplies,
        userId: uid,
        since: since,
        supplyFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.recipes,
        userId: uid,
        since: since,
        recipeFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.userPlants,
        userId: uid,
        since: since,
        userPlantFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.tasks,
        userId: uid,
        since: since,
        taskFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.notes,
        userId: uid,
        since: since,
        noteFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      // Child tables: no user_id column — RLS scopes them via the parent task.
      await _pull(
        _db.taskSubjects,
        userId: null,
        since: since,
        taskSubjectFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.taskReminders,
        userId: null,
        since: since,
        taskReminderFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
      await _pull(
        _db.taskSupplies,
        userId: null,
        since: since,
        taskSupplyFromRemote,
        updatedAt: (t) => t.updatedAt,
      ),
    ]) {
      total += r.count;
      if (r.maxUpdatedAt != null && r.maxUpdatedAt!.isAfter(maxTs)) {
        maxTs = r.maxUpdatedAt!;
      }
    }

    if (maxTs.isAfter(cursor)) await _writeCursor(maxTs);
    return total;
  }

  Future<({int count, DateTime? maxUpdatedAt})> _pull<T extends Table, D>(
    TableInfo<T, D> table,
    Insertable<D> Function(Map<String, dynamic>) fromRemote, {
    required String? userId,
    required String since,
    required GeneratedColumn<DateTime> Function(T) updatedAt,
  }) async {
    final rows = await _fetch(
      table.actualTableName,
      sinceIso: since,
      userId: userId,
    );
    if (rows.isEmpty) return (count: 0, maxUpdatedAt: null);

    DateTime? maxTs;
    await _db.transaction(() async {
      for (final remote in rows) {
        final ts = DateTime.parse(remote['updated_at'] as String);
        if (maxTs == null || ts.isAfter(maxTs!)) maxTs = ts;
        final row = fromRemote(remote);
        // LWW by updated_at: the cloud row wins only if it is at least as new as
        // the local one. A newer local edit (pending, not yet pushed) is kept —
        // its updated_at is greater, so the guard is false and nothing changes.
        await _db
            .into(table)
            .insert(
              row,
              onConflict: DoUpdate(
                (_) => row,
                where: (old) => updatedAt(old).isSmallerOrEqualValue(ts),
              ),
            );
      }
    });
    return (count: rows.length, maxUpdatedAt: maxTs);
  }

  Future<DateTime> _readCursor() async {
    final row = await (_db.select(
      _db.syncCursors,
    )..where((c) => c.name.equals(_cursorName))).getSingleOrNull();
    return row?.lastPulledAt ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  Future<void> _writeCursor(DateTime ts) => _db
      .into(_db.syncCursors)
      .insertOnConflictUpdate(
        SyncCursorsCompanion.insert(name: _cursorName, lastPulledAt: ts),
      );
}

@Riverpod(keepAlive: true)
SyncPullService? syncPullService(Ref ref) {
  if (kSupabaseUrl.isEmpty) return null;
  final client = Supabase.instance.client;
  final auth = ref.watch(authServiceProvider);
  return SyncPullService(ref.watch(databaseProvider), (
    table, {
    required sinceIso,
    userId,
  }) async {
    var query = client.from(table).select().gte('updated_at', sinceIso);
    if (userId != null) query = query.eq('user_id', userId);
    final data = await query;
    return data.cast<Map<String, dynamic>>();
  }, () => auth.userId);
}
