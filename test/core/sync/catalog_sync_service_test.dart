import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/catalog_sync_service.dart';

/// Returns canned catalog rows per table.
class _FakeCatalog {
  final Map<String, List<Map<String, dynamic>>> byTable = {};
  Future<List<Map<String, dynamic>>> call(String table) async =>
      byTable[table] ?? const [];
}

Map<String, dynamic> taskTypeRow(String id, {Map<String, String>? labels}) => {
      'id': id,
      'labels': labels ?? {'sl': id},
      'icon': 'x',
      'category': 'care',
      'requires_subject': false,
      'weather_sensitive': false,
      'consumes_supplies': false,
      'default_cadence': null,
    };

void main() {
  late AppDatabase db;
  late _FakeCatalog fake;
  late CatalogSyncService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fake = _FakeCatalog();
    service = CatalogSyncService(db, fake.call);
  });
  tearDown(() async => db.close());

  Future<TaskType?> taskType(String id) =>
      (db.select(db.taskTypes)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  test('inserts catalog rows from the cloud', () async {
    fake.byTable['task_type'] = [taskTypeRow('water'), taskTypeRow('mow')];
    fake.byTable['plant'] = [
      {'id': 'tomato', 'labels': {'sl': 'Paradižnik'}, 'category': 'veg'}
    ];

    final n = await service.pull();

    expect(n, 3);
    expect((await taskType('water'))!.icon, 'x');
    expect(await db.select(db.plants).get(), hasLength(1));
  });

  test('merges with the seed by slug — updates content, no duplicate', () async {
    // Seed row already present locally (different label).
    await db.into(db.taskTypes).insert(TaskTypesCompanion.insert(
          id: 'water',
          labels: jsonEncode({'sl': 'staro'}),
          icon: 'old',
          category: 'care',
        ));
    fake.byTable['task_type'] = [
      taskTypeRow('water', labels: {'sl': 'novo'})
    ];

    await service.pull();

    final all = await db.select(db.taskTypes).get();
    expect(all, hasLength(1)); // upsert merged, did not duplicate
    expect(all.single.labels, jsonEncode({'sl': 'novo'})); // cloud content wins
  });

  test('is idempotent — pulling twice keeps one row per id', () async {
    fake.byTable['task_type'] = [taskTypeRow('water')];
    await service.pull();
    await service.pull();
    expect(await db.select(db.taskTypes).get(), hasLength(1));
  });

  test('category_task_type insert-or-ignores duplicates', () async {
    await db.into(db.categoryTaskTypes).insert(
        CategoryTaskTypesCompanion.insert(
            category: 'veg', taskTypeId: 'water'));
    fake.byTable['category_task_type'] = [
      {'category': 'veg', 'task_type_id': 'water'}, // same composite PK
    ];

    // Must not throw on the duplicate PK.
    await service.pull();

    expect(await db.select(db.categoryTaskTypes).get(), hasLength(1));
  });
}
