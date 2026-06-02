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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2: track whether a task_supply consumption was booked into stock.
          if (from < 2) {
            await m.addColumn(taskSupplies, taskSupplies.applied);
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
