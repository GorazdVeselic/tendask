import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/tasks_repository.dart';

part 'tasks_providers.g.dart';

@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) {
  return TasksRepository(ref.watch(databaseProvider));
}

// Manual StreamProvider — riverpod_generator can't resolve drift part-file types
final pendingTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchPending();
});

final completedTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchCompleted();
});
