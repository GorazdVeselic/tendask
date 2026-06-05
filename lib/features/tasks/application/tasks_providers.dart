import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/location/location_repository.dart';
import '../../supplies/application/supplies_providers.dart';
import '../../weather/application/weather_service.dart';
import '../data/tasks_repository.dart';

part 'tasks_providers.g.dart';

@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) {
  final weather = ref.watch(weatherServiceProvider);
  return TasksRepository(
    ref.watch(databaseProvider),
    ref.watch(suppliesRepositoryProvider),
    weatherCapture: () async {
      final loc = await ref.read(gardenLocationProvider.future);
      final snapshot = await weather.capture(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      return snapshot == null ? null : jsonEncode(snapshot.toJson());
    },
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

/// Most recently touched task — for the "repeat last" shortcut on entry step 1.
final lastTaskProvider = StreamProvider.autoDispose<Task?>((ref) {
  return ref.watch(tasksRepositoryProvider).watchLast();
});

/// Per-type task counts — for the frequency sort of the entry type grid.
final taskTypeUsageProvider = StreamProvider.autoDispose<Map<String, int>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchTaskTypeUsage();
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

/// Task history for one plant instance — for the plant detail screen.
final tasksByPlantProvider =
    StreamProvider.autoDispose.family<List<Task>, String>((ref, userPlantId) {
  return ref.watch(tasksRepositoryProvider).watchByPlant(userPlantId);
});
