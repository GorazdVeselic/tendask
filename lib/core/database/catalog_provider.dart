import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_provider.dart';

final taskTypesMapProvider = FutureProvider<Map<String, TaskType>>((ref) async {
  final db = ref.watch(databaseProvider);
  final list = await db.select(db.taskTypes).get();
  return {for (final t in list) t.id: t};
});

final areasMapProvider = StreamProvider<Map<String, Area>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.areas)..where((a) => a.deleted.equals(false)))
      .watch()
      .map((list) => {for (final a in list) a.id: a});
});
