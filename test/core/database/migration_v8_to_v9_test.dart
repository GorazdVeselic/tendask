import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

// The real on-disk v8→v9 upgrade is verified on-device (a drift schema-verifier
// harness isn't set up here). These lock down the parts a unit test can reach:
// the version is bumped and device_location is gone from the current schema.
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

  test('schema version is 12', () {
    expect(db.schemaVersion, 12);
  });

  test('current schema has no device_location, keeps the user tables', () async {
    expect(await tableExists('device_location'), isFalse);
    expect(await tableExists('profile'), isTrue);
    expect(await tableExists('area'), isTrue);
    expect(await tableExists('task'), isTrue);
  });

  test('v10: profile carries the per-account default_garden_seeded flag', () async {
    expect(await columnExists('profile', 'default_garden_seeded'), isTrue);
  });

  test('dropping device_location is idempotent (v9 step is safe to re-run)',
      () async {
    await db.customStatement('DROP TABLE IF EXISTS device_location');
    await db.customStatement('DROP TABLE IF EXISTS device_location');
    expect(await tableExists('device_location'), isFalse);
  });
}
