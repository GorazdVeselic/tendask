import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../area_type.dart';
import '../sync/sync_status.dart';
import '../task_status.dart';
import 'tables/catalog_tables.dart';
import 'tables/sync_tables.dart';
import 'tables/user_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // catalog (read-only, seeded on first launch)
    TaskTypes,
    Plants,
    PlantSynonyms,
    CategoryTaskTypes,
    // user data (sync-ready: uuid / updated_at / deleted / sync_status)
    Profiles,
    Areas,
    UserPlants,
    Tasks,
    TaskSubjects,
    TaskReminders,
    Notes,
    Supplies,
    Recipes,
    TaskSupplies,
    // local-only (never synced)
    SyncCursors,
    LocalFlags,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for unit tests — do not use in production.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 11;

  /// Wipes user + device-local data: on sign-out (reset, [keepFlags] false →
  /// also clears onboarding flag) or on sign-in to another account ([keepFlags]
  /// true → keep onboarding flag, just drop the previous session's rows before
  /// pulling the new account's data). Catalog (public) is kept. Child tables
  /// first for FK order. Synced rows survive in the cloud and return on pull.
  Future<void> clearUserData({bool keepFlags = false}) async {
    await transaction(() async {
      for (final table in <TableInfo<Table, dynamic>>[
        taskSupplies,
        taskReminders,
        taskSubjects,
        notes,
        tasks,
        userPlants,
        recipes,
        supplies,
        areas,
        profiles,
        syncCursors,
      ]) {
        await delete(table).go();
      }
      if (!keepFlags) await delete(localFlags).go();
    });
  }

  /// Collects all of the user's rows into a JSON-serializable map for GDPR
  /// export. Excludes device-local-only tables (local_flag/sync_cursor are
  /// internal); the public catalog is omitted (not user data). Raw coordinates
  /// are never stored (FR-8) — only the derived H3 cells in profile are
  /// exported. sync_status is stripped — an internal sync detail, not content.
  Future<Map<String, dynamic>> exportUserData() async {
    List<Map<String, dynamic>> rows<D extends DataClass>(
      List<D> data,
    ) => data.map((r) {
      final json = r.toJson();
      json.remove('syncStatus');
      return json;
    }).toList();

    return {
      'schema_version': schemaVersion,
      'profile': rows(await select(profiles).get()),
      'area': rows(await select(areas).get()),
      'user_plant': rows(await select(userPlants).get()),
      'task': rows(await select(tasks).get()),
      'task_subject': rows(await select(taskSubjects).get()),
      'task_reminder': rows(await select(taskReminders).get()),
      'note': rows(await select(notes).get()),
      'supply': rows(await select(supplies).get()),
      'recipe': rows(await select(recipes).get()),
      'task_supply': rows(await select(taskSupplies).get()),
    };
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v2: track whether a task_supply consumption was booked into stock.
      if (from < 2) {
        await m.addColumn(taskSupplies, taskSupplies.applied);
      }
      // v3: subjects move to task_subject (M:N). Create the table, copy each
      // task's old area/plant into it, then drop the old columns from task.
      if (from < 3) {
        await m.createTable(taskSubjects);
        await customStatement(
          "INSERT INTO task_subject (id, task_id, user_plant_id, area_id, "
          "updated_at, deleted, sync_status) "
          "SELECT lower(hex(randomblob(16))), id, user_plant_id, area_id, "
          "updated_at, 0, 'pending' FROM task",
        );
        await m.alterTable(TableMigration(tasks));
      }
      // v4 adds task_type.consumes_supplies. Pre-release: no devices hold
      // data yet, so we rely on fresh install (onCreate + re-seed) rather
      // than a data-backfill migration. Add real migration steps here once
      // the app ships and existing DBs must survive upgrades.
      // v5: sync_cursor tracks the incremental-pull high-watermark (M6.3).
      if (from < 5) {
        await m.createTable(syncCursors);
      }
      // v6: device_location held the garden's raw coordinates device-local for
      // weather (M7.1b). Created via raw SQL because the drift table was dropped
      // in v9 (FR-8) — an old DB must still pass through this step before v9
      // drops it. DDL matches the former generated schema.
      if (from < 6) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS device_location ('
          'id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, '
          'latitude REAL NOT NULL, longitude REAL NOT NULL, '
          'updated_at INTEGER NOT NULL)',
        );
      }
      // v7: local_flag holds device-local UI flags (onboarding seen, M7.2).
      if (from < 7) {
        await m.createTable(localFlags);
      }
      // v8: notification settings (screen 22, M8.4) live in profile and sync.
      if (from < 8) {
        await m.addColumn(profiles, profiles.notificationSettings);
      }
      // v9: drop device_location — raw coordinates are no longer stored; weather
      // uses the H3 r7 cell centroid (FR-8). Device-local only, never synced, so
      // no Supabase impact.
      if (from < 9) {
        await customStatement('DROP TABLE IF EXISTS device_location');
      }
      // v10: profile.default_garden_seeded — the default-garden one-shot moves
      // from a device-local flag to the synced profile, so a reinstall no longer
      // re-seeds and pushes a duplicate (mirrors Supabase 0012).
      if (from < 10) {
        await m.addColumn(profiles, profiles.defaultGardenSeeded);
      }
      // v11: task.series_id groups instances of one recurring series (FR-5).
      // Additive nullable column; mirrors Supabase migration.
      if (from < 11) {
        await m.addColumn(tasks, tasks.seriesId);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tendask.db'));
    return NativeDatabase.createInBackground(file);
  });
}
