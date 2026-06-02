import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/task_status.dart';
import '../../supplies/data/supplies_repository.dart';

class TasksRepository {
  TasksRepository(this._db, this._supplies, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final SuppliesRepository _supplies;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<Task?> watchById(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Stream<List<Task>> watchPending() => (
        _db.select(_db.tasks)
          ..where((t) =>
              t.deleted.equals(false) &
              t.status.equalsValue(TaskStatus.waiting))
          ..orderBy([(t) => OrderingTerm.asc(t.date)])
      ).watch();

  Stream<List<Task>> watchCompleted() => (
        _db.select(_db.tasks)
          ..where((t) =>
              t.deleted.equals(false) &
              t.status.equalsValue(TaskStatus.done))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ).watch();

  /// Every non-deleted task (any status), oldest first — for the month calendar.
  Stream<List<Task>> watchAll() => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.date)])
      ).watch();

  /// Task history for one area (newest first), for the area detail screen.
  Stream<List<Task>> watchByArea(String areaId) => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false) & t.areaId.equals(areaId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ).watch();

  /// Newest task per area, keyed by areaId — for the "last: …" list subtitle.
  Stream<Map<String, Task>> watchLatestPerArea() => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ).watch().map((tasks) {
        final latest = <String, Task>{};
        for (final task in tasks) {
          latest.putIfAbsent(task.areaId, () => task);
        }
        return latest;
      });

  Future<Task?> byId(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> create({
    required String userId,
    required String areaId,
    required String taskTypeId,
    required DateTime date,
    String? userPlantId,
    TaskStatus status = TaskStatus.waiting,
    String? note,
    String? recurrence,
  }) async {
    final id = _uuid.v4();
    final now = _clock.now();
    await _db.into(_db.tasks).insert(TasksCompanion.insert(
      id: id,
      userId: userId,
      areaId: areaId,
      taskTypeId: taskTypeId,
      date: date.toUtc(),
      userPlantId: Value(userPlantId),
      status: Value(status),
      note: Value(note),
      recurrence: Value(recurrence),
      updatedAt: now,
    ));
    return id;
  }

  /// Edits the user-facing fields of a task; keeps drift types out of the UI.
  Future<void> updateTask({
    required String id,
    required String taskTypeId,
    required String areaId,
    required TaskStatus status,
    required DateTime date,
    required String? note,
    String? userPlantId,
  }) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        taskTypeId: Value(taskTypeId),
        areaId: Value(areaId),
        status: Value(status),
        date: Value(date.toUtc()),
        note: Value(note),
        userPlantId: Value(userPlantId),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> complete(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: const Value(TaskStatus.done),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value('pending'),
        ),
      );
      // Deduct supplies from stock now that the task is done.
      await _supplies.applyForTask(id);
    });
  }

  Future<void> softDelete(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          deleted: const Value(true),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value('pending'),
        ),
      );
      // Return any booked consumption to stock.
      await _supplies.revertForTask(id);
    });
  }

  Future<void> postponeOneDay(String id) async {
    final task = await byId(id);
    if (task == null) return;
    final now = _clock.now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        date: Value(task.date.add(const Duration(days: 1))),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> revertToWaiting(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: const Value(TaskStatus.waiting),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value('pending'),
        ),
      );
      // No longer done — return supplies to stock.
      await _supplies.revertForTask(id);
    });
  }

  Future<String> duplicate(String id) async {
    final task = await byId(id);
    if (task == null) throw StateError('Task $id not found');
    final newId = _uuid.v4();
    final now = _clock.now();
    await _db.into(_db.tasks).insert(TasksCompanion.insert(
      id: newId,
      userId: task.userId,
      areaId: task.areaId,
      taskTypeId: task.taskTypeId,
      date: task.date,
      userPlantId: Value(task.userPlantId),
      status: const Value(TaskStatus.waiting),
      note: Value(task.note),
      recurrence: Value(task.recurrence),
      updatedAt: now,
    ));
    return newId;
  }
}
