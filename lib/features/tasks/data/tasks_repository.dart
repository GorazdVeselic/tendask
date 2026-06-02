import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';

class TasksRepository {
  TasksRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<Task?> watchById(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Stream<List<Task>> watchPending() => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false) & t.status.equals('waiting'))
          ..orderBy([(t) => OrderingTerm.asc(t.date)])
      ).watch();

  Stream<List<Task>> watchCompleted() => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false) & t.status.equals('done'))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ).watch();

  Future<Task?> byId(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> create({
    required String userId,
    required String areaId,
    required String taskTypeId,
    required DateTime date,
    String? userPlantId,
    String status = 'waiting',
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
      date: date,
      userPlantId: Value(userPlantId),
      status: Value(status),
      note: Value(note),
      recurrence: Value(recurrence),
      updatedAt: now,
    ));
    return id;
  }

  Future<void> update(String id, TasksCompanion patch) async {
    final now = _clock.now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      patch.copyWith(updatedAt: Value(now), syncStatus: const Value('pending')),
    );
  }

  Future<void> complete(String id) async {
    final now = _clock.now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('done'),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = _clock.now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
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
    final now = _clock.now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('waiting'),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
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
      status: const Value('waiting'),
      note: Value(task.note),
      recurrence: Value(task.recurrence),
      updatedAt: now,
    ));
    return newId;
  }
}
