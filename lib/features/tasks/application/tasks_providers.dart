import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../supplies/application/supplies_providers.dart';
import '../data/tasks_repository.dart';

part 'tasks_providers.g.dart';

@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) {
  return TasksRepository(
    ref.watch(databaseProvider),
    ref.watch(suppliesRepositoryProvider),
  );
}

// Manual StreamProviders — riverpod_generator can't resolve drift part-file types
final pendingTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchPending();
});

final completedTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchCompleted();
});

final allTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchAll();
});

final taskByIdProvider =
    StreamProvider.autoDispose.family<Task?, String>((ref, id) {
  return ref.watch(tasksRepositoryProvider).watchById(id);
});

/// All subject links — used to resolve "for what" labels in task lists.
final allTaskSubjectsProvider =
    StreamProvider.autoDispose<List<TaskSubject>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchAllSubjects();
});

/// Subjects of a single task — for the task detail screen.
final taskSubjectsForTaskProvider =
    StreamProvider.autoDispose.family<List<TaskSubject>, String>((ref, id) {
  return ref.watch(tasksRepositoryProvider).watchSubjectsForTask(id);
});
