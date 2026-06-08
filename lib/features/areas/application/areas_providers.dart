import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../tasks/application/tasks_providers.dart';
import '../data/areas_repository.dart';

part 'areas_providers.g.dart';

@Riverpod(keepAlive: true)
AreasRepository areasRepository(Ref ref) {
  return AreasRepository(ref.watch(databaseProvider));
}

// Manual StreamProviders — riverpod_generator can't resolve drift part-file types.
final areasListProvider = StreamProvider.autoDispose<List<Area>>((ref) {
  return ref.watch(areasRepositoryProvider).watchAll();
});

final areasMapProvider = StreamProvider<Map<String, Area>>((ref) {
  return ref
      .watch(areasRepositoryProvider)
      .watchAll()
      .map((list) => {for (final a in list) a.id: a});
});

final areaByIdProvider = StreamProvider.autoDispose.family<Area?, String>((
  ref,
  id,
) {
  return ref.watch(areasRepositoryProvider).watchById(id);
});

final latestTaskPerAreaProvider = StreamProvider.autoDispose<Map<String, Task>>(
  (ref) {
    return ref.watch(tasksRepositoryProvider).watchLatestPerArea();
  },
);

final areaHistoryProvider = StreamProvider.autoDispose
    .family<List<Task>, String>((ref, areaId) {
      return ref.watch(tasksRepositoryProvider).watchByArea(areaId);
    });
