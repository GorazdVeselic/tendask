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

@DriftDatabase(tables: [
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
  // local-only sync bookkeeping (never synced)
  SyncCursors,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for unit tests — do not use in production.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

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
