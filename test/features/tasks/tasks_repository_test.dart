import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(DateTime now) : _now = now;
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late TasksRepository repo;

  const areaId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const userId = 'user-1';
  final t0 = DateTime.utc(2026, 6, 2, 8);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = _FakeClock(t0);
    repo = TasksRepository(
      db,
      SuppliesRepository(db, clock: clock),
      clock: clock,
    );

    await SeedService(db).runIfNeeded();
    await db
        .into(db.areas)
        .insert(
          AreasCompanion.insert(
            id: areaId,
            userId: userId,
            name: 'Vrt',
            type: const Value(AreaType.bed),
            updatedAt: t0,
          ),
        );
  });

  tearDown(() async => db.close());

  group('TasksRepository.create', () {
    test('returns a new UUID and task has correct defaults', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );

      final task = await repo.byId(id);
      expect(task, isNotNull);
      expect(task!.userId, userId);
      expect(task.status, TaskStatus.waiting);
      expect(task.deleted, false);
      expect(task.syncStatus, 'pending');
      expect(task.updatedAt.toUtc(), t0);

      final subjects = await repo.subjectsForTask(id);
      expect(subjects, hasLength(1));
      expect(subjects.first.areaId, areaId);
    });

    test('two creates produce distinct IDs', () async {
      final id1 = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      final id2 = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      expect(id1, isNot(id2));
    });
  });

  group('TasksRepository.watchPending', () {
    test('only returns non-deleted waiting tasks', () async {
      final id1 = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      final id2 = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );

      await repo.complete(id2);
      await repo.softDelete(
        await repo.create(
          userId: userId,
          subjects: const [TaskSubjectSpec.area(areaId)],
          taskTypeId: 'mow',
          date: t0,
        ),
      );

      final pending = await repo.watchPending().first;
      expect(pending.length, 1);
      expect(pending.first.id, id1);
    });
  });

  group('TasksRepository.complete', () {
    test('sets status=done, updates updatedAt and syncStatus', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );

      clock.advance(const Duration(minutes: 5));
      await repo.complete(id);

      final task = await repo.byId(id);
      expect(task!.status, TaskStatus.done);
      expect(task.syncStatus, 'pending');
      expect(task.updatedAt, isNot(t0));
    });
  });

  group('TasksRepository.softDelete', () {
    test('sets deleted=true and task disappears from watchPending', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );

      await repo.softDelete(id);

      final task = await repo.byId(id);
      expect(task!.deleted, true);

      final pending = await repo.watchPending().first;
      expect(pending, isEmpty);
    });

    test('cascades the soft-delete to children so the deletion syncs', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 0)],
      );

      await repo.softDelete(id);

      // Active (deleted=false) children are gone from the repo views...
      expect(await repo.subjectsForTask(id), isEmpty);
      expect(await repo.remindersForTask(id), isEmpty);

      // ...but the rows persist as deleted=true + pending, so the delete pushes.
      final reminder = (await db.select(db.taskReminders).get()).single;
      expect(reminder.deleted, true);
      expect(reminder.syncStatus, 'pending');
      final subject = (await db.select(db.taskSubjects).get()).single;
      expect(subject.deleted, true);
      expect(subject.syncStatus, 'pending');
    });
  });

  group('TasksRepository.postponeOneDay', () {
    test('advances date by exactly 1 day', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );

      await repo.postponeOneDay(id);

      final task = await repo.byId(id);
      expect(task!.date.toUtc(), t0.add(const Duration(days: 1)));
    });
  });

  group('TasksRepository.watchLast', () {
    test('returns the most recently touched non-deleted task', () async {
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      clock.advance(const Duration(minutes: 5));
      final id2 = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );

      expect((await repo.watchLast().first)?.id, id2);
    });

    test('skips deleted tasks and returns null when none remain', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );

      await repo.softDelete(id);

      expect(await repo.watchLast().first, isNull);
    });
  });

  group('TasksRepository.watchTaskTypeUsage', () {
    test('counts non-deleted tasks per type, excluding deleted', () async {
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      await repo.softDelete(
        await repo.create(
          userId: userId,
          subjects: const [TaskSubjectSpec.area(areaId)],
          taskTypeId: 'mow',
          date: t0,
        ),
      );

      final usage = await repo.watchTaskTypeUsage().first;
      expect(usage['water'], 2);
      expect(usage['mow'], 1);
      expect(usage.containsKey('prune'), false);
    });
  });

  group('TasksRepository.duplicate', () {
    test('creates a copy with a new ID and status=waiting', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        note: 'test note',
        status: TaskStatus.done,
      );

      final newId = await repo.duplicate(id);

      expect(newId, isNot(id));
      final copy = await repo.byId(newId);
      expect(copy!.status, TaskStatus.waiting);
      expect(copy.note, 'test note');
      expect(copy.taskTypeId, 'mow');

      final copySubjects = await repo.subjectsForTask(newId);
      expect(copySubjects.single.areaId, areaId);
    });
  });

  group('TasksRepository.reminderReconcileInputs', () {
    test('returns only waiting tasks with reminders, each with its '
        'reminders and subjects', () async {
      final withReminder = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 60, time: '09:00')],
      );
      // No reminder → excluded.
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );
      // Done → not pending, excluded even with a reminder.
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        status: TaskStatus.done,
        reminders: const [ReminderSpec(offsetMinutes: 30)],
      );

      final inputs = await repo.reminderReconcileInputs();

      expect(inputs, hasLength(1));
      final only = inputs.single;
      expect(only.task.id, withReminder);
      expect(only.reminders.single.offset, 60);
      expect(only.reminders.single.reminderTime, '09:00');
      expect(only.subjects.single.areaId, areaId);
    });

    test('orders reminders by offset ascending', () async {
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [
          ReminderSpec(offsetMinutes: 120),
          ReminderSpec(offsetMinutes: 30),
        ],
      );

      final inputs = await repo.reminderReconcileInputs();
      expect(
        inputs.single.reminders.map((r) => r.offset).toList(),
        [30, 120],
      );
    });

    test('returns empty when no pending tasks', () async {
      expect(await repo.reminderReconcileInputs(), isEmpty);
    });

    test('groups subjects with their own task, never mixed across tasks', () async {
      const areaId2 = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
      await db
          .into(db.areas)
          .insert(
            AreasCompanion.insert(
              id: areaId2,
              userId: userId,
              name: 'Vrt 2',
              type: const Value(AreaType.bed),
              updatedAt: t0,
            ),
          );
      final taskA = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 10)],
      );
      final taskB = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId2)],
        taskTypeId: 'water',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 20)],
      );

      final byTask = {
        for (final i in await repo.reminderReconcileInputs()) i.task.id: i,
      };
      expect(byTask[taskA]!.subjects.single.areaId, areaId);
      expect(byTask[taskB]!.subjects.single.areaId, areaId2);
    });

    test('excludes deleted reminders and deleted subjects', () async {
      await repo.create(
        userId: userId,
        subjects: const [
          TaskSubjectSpec.area(areaId),
          TaskSubjectSpec.area(areaId),
        ],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [
          ReminderSpec(offsetMinutes: 10),
          ReminderSpec(offsetMinutes: 20),
        ],
      );

      // Soft-delete one reminder and one subject directly.
      final rem20 = (await db.select(db.taskReminders).get()).firstWhere(
        (r) => r.offset == 20,
      );
      await (db.update(db.taskReminders)..where((r) => r.id.equals(rem20.id)))
          .write(const TaskRemindersCompanion(deleted: Value(true)));
      final firstSubject = (await db.select(db.taskSubjects).get()).first;
      await (db.update(
        db.taskSubjects,
      )..where((s) => s.id.equals(firstSubject.id))).write(
        const TaskSubjectsCompanion(deleted: Value(true)),
      );

      final only = (await repo.reminderReconcileInputs()).single;
      expect(only.reminders.single.offset, 10);
      expect(only.subjects, hasLength(1));
    });

    test('keeps a task whose reminder has no subjects (subjects == [])', () async {
      await repo.create(
        userId: userId,
        subjects: const [],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 10)],
      );

      final only = (await repo.reminderReconcileInputs()).single;
      expect(only.subjects, isEmpty);
      expect(only.reminders.single.offset, 10);
    });
  });

  group('TasksRepository.reminderScheduleInputs', () {
    test('one row per active reminder, joined to the task date', () async {
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [
          ReminderSpec(offsetMinutes: 60, time: '09:00'),
          ReminderSpec(offsetMinutes: 30),
        ],
      );

      final rows = await repo.reminderScheduleInputs();
      expect(rows, hasLength(2));
      for (final r in rows) {
        expect(r.taskDate.toUtc(), t0);
      }
      final byOffset = {for (final r in rows) r.offsetMinutes: r.reminderTime};
      expect(byOffset[60], '09:00');
      expect(byOffset.containsKey(30), isTrue);
      expect(byOffset[30], isNull);
    });

    test('excludes deleted reminders and reminders of deleted/done tasks', () async {
      // Active waiting task with reminder → included.
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 10)],
      );
      // Reminder soft-deleted → excluded.
      final bId = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 20)],
      );
      await (db.update(db.taskReminders)..where((r) => r.taskId.equals(bId)))
          .write(const TaskRemindersCompanion(deleted: Value(true)));
      // Task soft-deleted, reminder left active → excluded by the join.
      final cId = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        reminders: const [ReminderSpec(offsetMinutes: 30)],
      );
      await (db.update(db.tasks)..where((t) => t.id.equals(cId)))
          .write(const TasksCompanion(deleted: Value(true)));
      // Done task with reminder → excluded (join filters status=waiting).
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
        status: TaskStatus.done,
        reminders: const [ReminderSpec(offsetMinutes: 40)],
      );

      final rows = await repo.reminderScheduleInputs();
      expect(rows, hasLength(1));
      expect(rows.single.offsetMinutes, 10);
    });

    test('a task without reminders contributes nothing', () async {
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      expect(await repo.reminderScheduleInputs(), isEmpty);
    });

    test('returns empty on an empty database', () async {
      expect(await repo.reminderScheduleInputs(), isEmpty);
    });
  });

  group('TasksRepository.totalCount', () {
    test('is 0 on an empty database', () async {
      expect(await repo.totalCount(), 0);
    });

    test('counts waiting and done, excludes soft-deleted', () async {
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'mow',
        date: t0,
      );
      await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
        status: TaskStatus.done,
      );
      await repo.softDelete(
        await repo.create(
          userId: userId,
          subjects: const [TaskSubjectSpec.area(areaId)],
          taskTypeId: 'mow',
          date: t0,
        ),
      );

      expect(await repo.totalCount(), 2);
    });
  });
}
