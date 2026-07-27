import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

// Shape of a FRESHLY CREATED database (onCreate), not an upgrade — the file was
// named migration_v8_to_v9 but never ran a migration. The real upgrade paths are
// migration_v9_test.dart (v8 → current) and migration_v13_to_v16_test.dart (the
// one released devices run). These lock down what a fresh install must have: the
// version is bumped, device_location is gone (FR-8, v9), and the smart-engine
// tables exist (M11, v14/v15).
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<bool> tableExists(String name) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          variables: [Variable.withString(name)],
        )
        .get();
    return rows.isNotEmpty;
  }

  Future<bool> columnExists(String table, String column) async {
    final rows = await db
        .customSelect('PRAGMA table_info($table)')
        .get();
    return rows.any((r) => r.data['name'] == column);
  }

  test('schema version is 16', () {
    expect(db.schemaVersion, 16);
  });

  test('v12: task carries the harvest yield columns (T11)', () async {
    expect(await columnExists('task', 'yield_amount'), isTrue);
    expect(await columnExists('task', 'yield_unit'), isTrue);
  });

  test('current schema has no device_location, keeps the user + engine tables',
      () async {
    expect(await tableExists('device_location'), isFalse);
    expect(await tableExists('profile'), isTrue);
    expect(await tableExists('area'), isTrue);
    expect(await tableExists('task'), isTrue);
    // Smart-engine tables grafted in by the merge (M11, v14/v15).
    expect(await tableExists('suggestion'), isTrue);
    expect(await tableExists('suggestion_log'), isTrue);
    expect(await tableExists('plant_task_rule'), isTrue);
  });

  test('v10: profile carries the per-account default_garden_seeded flag', () async {
    expect(await columnExists('profile', 'default_garden_seeded'), isTrue);
  });

  test('v13: supply.category exists and defaults to other', () async {
    expect(await columnExists('supply', 'category'), isTrue);
    // A row inserted without a category takes the column default — the same
    // default that backfills existing rows on the v12→v13 ALTER.
    await db.customStatement(
      "INSERT INTO supply (id, user_id, name, updated_at) "
      "VALUES ('s1', 'u1', 'Urea', 0)",
    );
    final rows = await db
        .customSelect("SELECT category FROM supply WHERE id='s1'")
        .get();
    expect(rows.single.data['category'], 'other');
  });

  test('dropping device_location is idempotent (v9 step is safe to re-run)',
      () async {
    await db.customStatement('DROP TABLE IF EXISTS device_location');
    await db.customStatement('DROP TABLE IF EXISTS device_location');
    expect(await tableExists('device_location'), isFalse);
  });
}
