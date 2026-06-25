import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_provider.dart';

// Streams (not futures) so a catalog pull (M6.3b) upserting rows reactively
// refreshes every screen — the seed shows immediately, the cloud refresh lands
// without a manual reload.

final taskTypesMapProvider = StreamProvider<Map<String, TaskType>>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .select(db.taskTypes)
      .watch()
      .map((list) => {for (final t in list) t.id: t});
});

final plantsListProvider = StreamProvider<List<Plant>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.plants).watch();
});

final plantsMapProvider = StreamProvider<Map<String, Plant>>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .select(db.plants)
      .watch()
      .map((list) => {for (final p in list) p.id: p});
});

/// Maps a task type id to the set of plant categories it applies to
/// (category_task_type). A type absent from the map (or with an empty set) has
/// no known restriction — callers treat that as "applies to all".
final taskTypeCategoriesProvider = StreamProvider<Map<String, Set<String>>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return db.select(db.categoryTaskTypes).watch().map((rows) {
    final out = <String, Set<String>>{};
    for (final r in rows) {
      (out[r.taskTypeId] ??= <String>{}).add(r.category);
    }
    return out;
  });
});
