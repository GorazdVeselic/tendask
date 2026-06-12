import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/seed/catalog_seed.dart';
import 'app_database.dart';

class SeedService {
  const SeedService(this._db);

  final AppDatabase _db;

  Future<void> runIfNeeded() async {
    final existing = await (_db.select(_db.taskTypes)..limit(1)).get();
    if (existing.isNotEmpty) return;

    await _db.transaction(() async {
      // task_types and plants have no FK dependency on each other
      await _db.batch((batch) {
        for (final t in CatalogSeed.taskTypes) {
          batch.insert(_db.taskTypes, _taskTypeCompanion(t));
        }
        for (final p in CatalogSeed.plants) {
          batch.insert(_db.plants, _plantCompanion(p));
        }
      });

      // category_task_type has FK on task_type — insert after
      await _db.batch((batch) {
        for (final (category, taskTypeId) in CatalogSeed.categoryMatrix) {
          batch.insert(
            _db.categoryTaskTypes,
            CategoryTaskTypesCompanion.insert(
              category: category,
              taskTypeId: taskTypeId,
            ),
          );
        }
      });
    });
  }

  TaskTypesCompanion _taskTypeCompanion(TaskTypeSeed t) {
    return TaskTypesCompanion.insert(
      id: t.id,
      labels: jsonEncode({'sl': t.sl, 'en': t.en, 'de': t.de}),
      icon: t.icon,
      category: t.category,
      requiresSubject: Value(t.requiresSubject),
      weatherSensitive: Value(t.weatherSensitive),
      consumesSupplies: Value(t.consumesSupplies),
      defaultCadence: Value(t.defaultCadence),
      seasonal: Value(t.seasonal),
    );
  }

  PlantsCompanion _plantCompanion(PlantSeed p) {
    return PlantsCompanion.insert(
      id: p.id,
      labels: jsonEncode({'sl': p.sl, 'en': p.en, 'de': p.de}),
      category: p.category,
      icon: Value(p.icon),
      scientificName: Value(p.scientificName),
    );
  }
}
