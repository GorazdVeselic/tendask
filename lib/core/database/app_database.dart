import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tendask.db'));
    return NativeDatabase.createInBackground(file);
  });
}
