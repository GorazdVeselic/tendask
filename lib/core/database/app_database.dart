import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../area_type.dart';
import '../task_status.dart';
import 'tables/catalog_tables.dart';
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for unit tests — do not use in production.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

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
          // v4: flag catalog types that draw from stock. Seed only runs on an
          // empty DB, so backfill the known supply-consuming types here.
          if (from < 4) {
            await m.addColumn(taskTypes, taskTypes.consumesSupplies);
            await customStatement(
              "UPDATE task_type SET consumes_supplies = 1 "
              "WHERE id IN ('fertilize', 'treat', 'lawn_weed_moss', 'lime')",
            );
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
