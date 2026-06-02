import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_provider.dart';

final taskTypesMapProvider = FutureProvider<Map<String, TaskType>>((ref) async {
  final db = ref.watch(databaseProvider);
  final list = await db.select(db.taskTypes).get();
  return {for (final t in list) t.id: t};
});

final plantsListProvider = FutureProvider<List<Plant>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.select(db.plants).get();
});

final plantsMapProvider = FutureProvider<Map<String, Plant>>((ref) async {
  final list = await ref.watch(plantsListProvider.future);
  return {for (final p in list) p.id: p};
});
