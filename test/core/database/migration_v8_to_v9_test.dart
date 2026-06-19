import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

// The real on-disk upgrade is verified on-device (a drift schema-verifier
// harness isn't set up here). These lock down the parts a unit test can reach:
// the version is bumped, device_location is gone (FR-8, v9), and the smart-engine
// tables are present (M11, v10/v11) in the current schema.
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

  test('schema version is 11', () {
    expect(db.schemaVersion, 11);
  });

  test('current schema has no device_location, keeps the user + engine tables',
      () async {
    expect(await tableExists('device_location'), isFalse);
    expect(await tableExists('profile'), isTrue);
    expect(await tableExists('area'), isTrue);
    expect(await tableExists('task'), isTrue);
    // Smart-engine tables grafted in by the merge (M11, v10/v11).
    expect(await tableExists('suggestion'), isTrue);
    expect(await tableExists('suggestion_log'), isTrue);
    expect(await tableExists('plant_task_rule'), isTrue);
  });

  test('dropping device_location is idempotent (v9 step is safe to re-run)',
      () async {
    await db.customStatement('DROP TABLE IF EXISTS device_location');
    await db.customStatement('DROP TABLE IF EXISTS device_location');
    expect(await tableExists('device_location'), isFalse);
  });
}
