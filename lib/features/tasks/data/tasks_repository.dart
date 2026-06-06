import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/task_status.dart';
import '../../supplies/data/supplies_repository.dart';

/// Captures a weather snapshot as JSON (or null when offline/unavailable).
/// Injected so the repo stays agnostic of the weather feature — composition,
/// not a features→features dependency (the provider wires it to WeatherService).
typedef WeatherCapture = Future<String?> Function();

/// A subject on the repository boundary: a plant OR an area-as-subject.
/// Keeps drift types out of the UI (see CLAUDE.md — no Companion in signatures).
class TaskSubjectSpec {
  const TaskSubjectSpec({this.userPlantId, this.areaId})
      : assert(userPlantId != null || areaId != null,
            'A subject must reference a plant or an area');
  const TaskSubjectSpec.plant(String userPlantId)
      : this(userPlantId: userPlantId);
  const TaskSubjectSpec.area(String areaId) : this(areaId: areaId);

  final String? userPlantId;
  final String? areaId;
}

/// A reminder on the repository boundary. Stored now; the actual scheduling
/// (flutter_local_notifications) lands in M8 — this only persists the model.
class ReminderSpec {
  const ReminderSpec({required this.offsetMinutes, this.time});

  /// Minutes before the task date; 0 = at event time.
  final int offsetMinutes;

  /// "HH:mm" time of day for the notification; null = use the task's own time.
  final String? time;
}

class TasksRepository {
  TasksRepository(
    this._db,
    this._supplies, {
    this._clock = const SystemClock(),
    this._weatherCapture,
  });

  final AppDatabase _db;
  final SuppliesRepository _supplies;
  final Clock _clock;
  final WeatherCapture? _weatherCapture;
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

  /// One-shot snapshot of waiting (non-deleted) tasks — for reminder reconcile.
  Future<List<Task>> pendingTasks() => (
        _db.select(_db.tasks)
          ..where((t) =>
              t.deleted.equals(false) &
              t.status.equalsValue(TaskStatus.waiting))
      ).get();

  /// Every non-deleted task (any status), oldest first — for the month calendar.
  Stream<List<Task>> watchAll() => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.date)])
      ).watch();

  /// The most recently touched task — drives the "repeat last" shortcut. We sort
  /// by `updated_at` (no `created_at` column) so the newest entry surfaces first.
  Stream<Task?> watchLast() => (
        _db.select(_db.tasks)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1)
      ).watchSingleOrNull();

  /// How many (non-deleted) tasks exist per task type — drives the per-user
  /// frequency sort of the type grid (most used first).
  Stream<Map<String, int>> watchTaskTypeUsage() {
    final count = _db.tasks.id.count();
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([_db.tasks.taskTypeId, count])
      ..where(_db.tasks.deleted.equals(false))
      ..groupBy([_db.tasks.taskTypeId]);
    return query.watch().map((rows) => {
          for (final row in rows)
            row.read(_db.tasks.taskTypeId)!: row.read(count) ?? 0,
        });
  }

  // ── Subjects ────────────────────────────────────────────────────────────

  /// All non-deleted subject links — for resolving subject labels in lists.
  Stream<List<TaskSubject>> watchAllSubjects() =>
      (_db.select(_db.taskSubjects)..where((s) => s.deleted.equals(false)))
          .watch();

  /// Subjects of one task (newest-relevant for the detail screen).
  Stream<List<TaskSubject>> watchSubjectsForTask(String taskId) =>
      (_db.select(_db.taskSubjects)
            ..where((s) => s.taskId.equals(taskId) & s.deleted.equals(false)))
          .watch();

  Future<List<TaskSubject>> subjectsForTask(String taskId) =>
      (_db.select(_db.taskSubjects)
            ..where((s) => s.taskId.equals(taskId) & s.deleted.equals(false)))
          .get();

  // ── Reminders ─────────────────────────────────────────────────────────────

  Future<List<TaskReminder>> remindersForTask(String taskId) =>
      (_db.select(_db.taskReminders)
            ..where((r) => r.taskId.equals(taskId) & r.deleted.equals(false))
            ..orderBy([(r) => OrderingTerm.asc(r.offset)]))
          .get();

  /// Task ids that have at least one active reminder — drives the bell marker in
  /// task lists. Reactive (drift stream).
  Stream<Set<String>> watchTaskIdsWithReminders() {
    final taskId = _db.taskReminders.taskId;
    final query = _db.selectOnly(_db.taskReminders, distinct: true)
      ..addColumns([taskId])
      ..where(_db.taskReminders.deleted.equals(false));
    return query.watch().map((rows) => {
          for (final row in rows) ?row.read(taskId),
        });
  }

  /// Task history for one area (newest first): tasks whose subject is the area
  /// itself OR a plant located in that area. Deduped by task id.
  Stream<List<Task>> watchByArea(String areaId) {
    final query = _db.select(_db.tasks).join([
      innerJoin(
        _db.taskSubjects,
        _db.taskSubjects.taskId.equalsExp(_db.tasks.id) &
            _db.taskSubjects.deleted.equals(false),
      ),
      leftOuterJoin(
        _db.userPlants,
        _db.userPlants.id.equalsExp(_db.taskSubjects.userPlantId),
      ),
    ])
      ..where(_db.tasks.deleted.equals(false) &
          (_db.taskSubjects.areaId.equals(areaId) |
              _db.userPlants.areaId.equals(areaId)))
      ..orderBy([OrderingTerm.desc(_db.tasks.date)]);
    return query.watch().map(_dedupTasks);
  }

  /// Task history for one plant instance (newest first).
  Stream<List<Task>> watchByPlant(String userPlantId) {
    final query = _db.select(_db.tasks).join([
      innerJoin(
        _db.taskSubjects,
        _db.taskSubjects.taskId.equalsExp(_db.tasks.id) &
            _db.taskSubjects.deleted.equals(false) &
            _db.taskSubjects.userPlantId.equals(userPlantId),
      ),
    ])
      ..where(_db.tasks.deleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.tasks.date)]);
    return query.watch().map(_dedupTasks);
  }

  /// Newest task per area (direct subject or via a plant in that area) — for the
  /// "last: …" subtitle in the garden list.
  Stream<Map<String, Task>> watchLatestPerArea() {
    final query = _db.select(_db.tasks).join([
      innerJoin(
        _db.taskSubjects,
        _db.taskSubjects.taskId.equalsExp(_db.tasks.id) &
            _db.taskSubjects.deleted.equals(false),
      ),
      leftOuterJoin(
        _db.userPlants,
        _db.userPlants.id.equalsExp(_db.taskSubjects.userPlantId),
      ),
    ])
      ..where(_db.tasks.deleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.tasks.date)]);
    return query.watch().map((rows) {
      final latest = <String, Task>{};
      for (final row in rows) {
        final task = row.readTable(_db.tasks);
        final subject = row.readTable(_db.taskSubjects);
        final plant = row.readTableOrNull(_db.userPlants);
        final areaId = subject.areaId ?? plant?.areaId;
        if (areaId != null) latest.putIfAbsent(areaId, () => task);
      }
      return latest;
    });
  }

  List<Task> _dedupTasks(List<TypedResult> rows) {
    final seen = <String>{};
    final result = <Task>[];
    for (final row in rows) {
      final task = row.readTable(_db.tasks);
      if (seen.add(task.id)) result.add(task);
    }
    return result;
  }

  Future<Task?> byId(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ── Mutations ───────────────────────────────────────────────────────────

  Future<String> create({
    required String userId,
    required String taskTypeId,
    required DateTime date,
    required List<TaskSubjectSpec> subjects,
    TaskStatus status = TaskStatus.waiting,
    String? note,
    String? recurrence,
    List<ReminderSpec> reminders = const [],
  }) async {
    final id = _uuid.v4();
    final now = _clock.now();
    await _db.transaction(() async {
      await _db.into(_db.tasks).insert(TasksCompanion.insert(
            id: id,
            userId: userId,
            taskTypeId: taskTypeId,
            date: date.toUtc(),
            status: Value(status),
            note: Value(note),
            recurrence: Value(recurrence),
            updatedAt: now,
          ));
      await _insertSubjects(id, subjects, now);
      await _insertReminders(id, reminders, now);
    });
    // Logged as already done → freeze a weather snapshot (§7.10).
    if (status == TaskStatus.done) unawaited(_captureWeather(id));
    return id;
  }

  /// Edits the user-facing fields of a task and replaces its subjects.
  Future<void> updateTask({
    required String id,
    required String taskTypeId,
    required TaskStatus status,
    required DateTime date,
    required String? note,
    required List<TaskSubjectSpec> subjects,
    List<ReminderSpec> reminders = const [],
  }) async {
    final now = _clock.now();
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          taskTypeId: Value(taskTypeId),
          status: Value(status),
          date: Value(date.toUtc()),
          note: Value(note),
          updatedAt: Value(now),
          syncStatus: const Value(kSyncPending),
        ),
      );
      // Soft-delete current subjects (so the change syncs) then insert fresh.
      await (_db.update(_db.taskSubjects)
            ..where((s) => s.taskId.equals(id) & s.deleted.equals(false)))
          .write(TaskSubjectsCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ));
      await _insertSubjects(id, subjects, now);
      // Same soft-delete-then-reinsert for reminders.
      await (_db.update(_db.taskReminders)
            ..where((r) => r.taskId.equals(id) & r.deleted.equals(false)))
          .write(TaskRemindersCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ));
      await _insertReminders(id, reminders, now);
    });
  }

  Future<void> _insertSubjects(
    String taskId,
    List<TaskSubjectSpec> subjects,
    DateTime now,
  ) async {
    for (final s in subjects) {
      await _db.into(_db.taskSubjects).insert(TaskSubjectsCompanion.insert(
            id: _uuid.v4(),
            taskId: taskId,
            userPlantId: Value(s.userPlantId),
            areaId: Value(s.areaId),
            updatedAt: now,
          ));
    }
  }

  Future<void> _insertReminders(
    String taskId,
    List<ReminderSpec> reminders,
    DateTime now,
  ) async {
    for (final r in reminders) {
      await _db.into(_db.taskReminders).insert(TaskRemindersCompanion.insert(
            id: _uuid.v4(),
            taskId: taskId,
            offset: r.offsetMinutes,
            reminderTime: Value(r.time),
            updatedAt: now,
          ));
    }
  }

  Future<void> complete(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: const Value(TaskStatus.done),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value(kSyncPending),
        ),
      );
      // Deduct supplies from stock now that the task is done.
      await _supplies.applyForTask(id);
    });
    // Freeze a weather snapshot for the moment of completion (§7.10).
    unawaited(_captureWeather(id));
  }

  /// Fetches a weather snapshot (fire-and-forget) and stores it only if the task
  /// still has none — the snapshot is frozen and never overwritten. Offline
  /// (capture returns null) leaves `weather` empty, to be filled another time.
  Future<void> _captureWeather(String id) async {
    final capture = _weatherCapture;
    if (capture == null) return;
    final json = await capture();
    if (json == null) return;
    await (_db.update(_db.tasks)
          ..where((t) =>
              t.id.equals(id) &
              t.weather.isNull() &
              t.deleted.equals(false)))
        .write(TasksCompanion(
      weather: Value(json),
      updatedAt: Value(_clock.now()),
      syncStatus: const Value(kSyncPending),
    ));
  }

  Future<void> softDelete(String id) async {
    final now = _clock.now();
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          syncStatus: const Value(kSyncPending),
        ),
      );
      // Cascade the soft-delete to children so the deletion syncs (mirrors
      // updateTask) — otherwise child rows stay deleted=false in the cloud.
      await (_db.update(_db.taskSubjects)
            ..where((s) => s.taskId.equals(id) & s.deleted.equals(false)))
          .write(TaskSubjectsCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ));
      await (_db.update(_db.taskReminders)
            ..where((r) => r.taskId.equals(id) & r.deleted.equals(false)))
          .write(TaskRemindersCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ));
      // Return any booked consumption to stock, then soft-delete the links.
      await _supplies.revertForTask(id);
      await _supplies.softDeleteForTask(id);
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
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  /// Moves a task to a new date (the "move" quick action). Caller passes a
  /// local DateTime; repo normalizes to UTC.
  Future<void> reschedule(String id, DateTime date) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        date: Value(date.toUtc()),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  Future<void> revertToWaiting(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: const Value(TaskStatus.waiting),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value(kSyncPending),
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
    await _db.transaction(() async {
      await _db.into(_db.tasks).insert(TasksCompanion.insert(
            id: newId,
            userId: task.userId,
            taskTypeId: task.taskTypeId,
            date: task.date,
            status: const Value(TaskStatus.waiting),
            note: Value(task.note),
            recurrence: Value(task.recurrence),
            updatedAt: now,
          ));
      final subs = await subjectsForTask(id);
      await _insertSubjects(
        newId,
        [
          for (final s in subs)
            TaskSubjectSpec(userPlantId: s.userPlantId, areaId: s.areaId),
        ],
        now,
      );
      final reminders = await remindersForTask(id);
      await _insertReminders(
        newId,
        [
          for (final r in reminders)
            ReminderSpec(offsetMinutes: r.offset, time: r.reminderTime),
        ],
        now,
      );
    });
    return newId;
  }
}
