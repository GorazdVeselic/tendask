import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'remote_mappers.dart';

part 'catalog_sync_service.g.dart';

/// Reads every row of a public catalog table. No incremental cursor: the catalog
/// is tiny and has no updated_at, so it is full-pulled.
typedef RemoteSelectAll = Future<List<Map<String, dynamic>>> Function(
    String table);

/// Pulls the read-only catalog (task_type, plant, category_task_type) from the
/// cloud into drift. Public-read, so no session is required. Ids are stable
/// slugs from a single source ([CatalogSeed]) → the upsert merges into seeded
/// rows instead of duplicating; the cloud is the source of truth for content.
class CatalogSyncService {
  CatalogSyncService(this._db, this._fetchAll);

  final AppDatabase _db;
  final RemoteSelectAll _fetchAll;

  /// Returns the number of catalog rows applied. task_type/plant upsert on the
  /// slug PK; category_task_type only has PK columns, so it inserts-or-ignores
  /// (matching the cloud seed's `on conflict do nothing`).
  Future<int> pull() async {
    var n = 0;
    n += await _upsert(_db.taskTypes, taskTypeFromRemote);
    n += await _upsert(_db.plants, plantFromRemote);
    n += await _ignoreDup(_db.categoryTaskTypes, categoryTaskTypeFromRemote);
    return n;
  }

  Future<int> _upsert<T extends Table, D>(
    TableInfo<T, D> table,
    Insertable<D> Function(Map<String, dynamic>) fromRemote,
  ) async {
    final rows = await _fetchAll(table.actualTableName);
    if (rows.isEmpty) return 0;
    await _db.batch((b) {
      for (final r in rows) {
        final row = fromRemote(r);
        b.insert(table, row, onConflict: DoUpdate((_) => row));
      }
    });
    return rows.length;
  }

  Future<int> _ignoreDup<T extends Table, D>(
    TableInfo<T, D> table,
    Insertable<D> Function(Map<String, dynamic>) fromRemote,
  ) async {
    final rows = await _fetchAll(table.actualTableName);
    if (rows.isEmpty) return 0;
    await _db.batch((b) {
      for (final r in rows) {
        b.insert(table, fromRemote(r), mode: InsertMode.insertOrIgnore);
      }
    });
    return rows.length;
  }
}

@Riverpod(keepAlive: true)
CatalogSyncService? catalogSyncService(Ref ref) {
  if (kSupabaseUrl.isEmpty) return null;
  final client = Supabase.instance.client;
  return CatalogSyncService(
    ref.watch(databaseProvider),
    (table) async {
      final data = await client.from(table).select();
      return data.cast<Map<String, dynamic>>();
    },
  );
}
