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
