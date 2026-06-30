import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/data/recurrence.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
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
    repo = TasksRepository(db, SuppliesRepository(db, clock: clock), clock: clock);
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

  Future<String> createRecurring({
    required String recurrence,
    List<ReminderSpec> reminders = const [],
    DateTime? date,
  }) => repo.create(
    userId: userId,
    subjects: const [TaskSubjectSpec.area(areaId)],
    taskTypeId: 'water',
    date: date ?? t0,
    recurrence: recurrence,
    reminders: reminders,
  );

  Future<Task> pendingOne() async => (await repo.watchPending().first).single;

  group('create assigns a series id', () {
    test('a one-off has no series id', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );
      expect((await repo.byId(id))!.seriesId, isNull);
    });

    test('a recurring task starts a series', () async {
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 7).encode(),
      );
      expect((await repo.byId(id))!.seriesId, isNotNull);
    });
  });

  group('complete materializes the next instance', () {
    test('next is waiting, anchored on the scheduled date, +interval', () async {
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 7).encode(),
      );
      // Complete late — the anchor is the scheduled date, not "now".
      clock.advance(const Duration(days: 3));
      final next = await repo.complete(id);

      expect(next, isNotNull);
      final child = await pendingOne();
      expect(child.id, isNot(id));
      expect(child.status, TaskStatus.waiting);
      expect(child.date.toUtc(), DateTime.utc(2026, 6, 9, 8));
      expect(child.recurrence, const Recurrence(everyDays: 7).encode());
    });

    test('child inherits subjects, reminders and series id', () async {
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 1).encode(),
        reminders: const [ReminderSpec(offsetMinutes: 60)],
      );
      final parentSeries = (await repo.byId(id))!.seriesId;
      await repo.complete(id);

      final child = await pendingOne();
      expect(child.seriesId, parentSeries);
      expect(await repo.subjectsForTask(child.id), hasLength(1));
      final reminders = await repo.remindersForTask(child.id);
      expect(reminders, hasLength(1));
      expect(reminders.first.offset, 60);
    });

    test('one-off completion spawns nothing', () async {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'water',
        date: t0,
      );
      expect(await repo.complete(id), isNull);
      expect(await repo.watchPending().first, isEmpty);
    });
  });

  group('capped series', () {
    test('produces exactly N instances, last one is terminal', () async {
      // total N = 3 → remaining = 2 on the first instance.
      await createRecurring(
        recurrence: const Recurrence(everyDays: 1, remaining: 2).encode(),
      );

      var rounds = 0;
      while (true) {
        final pending = await repo.watchPending().first;
        if (pending.isEmpty) break;
        await repo.complete(pending.single.id);
        if (++rounds > 10) fail('series did not terminate');
      }

      expect(rounds, 3);
      final all = (await db.select(db.tasks).get())
          .where((t) => !t.deleted)
          .toList();
      expect(all, hasLength(3));
      // Every instance shares one series; exactly one is terminal (no rule).
      expect(all.map((t) => t.seriesId).toSet(), hasLength(1));
      expect(all.where((t) => t.recurrence == null), hasLength(1));
    });
  });

  group('revertToWaiting', () {
    test('is blocked on a completed recurring instance', () async {
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 7).encode(),
      );
      await repo.complete(id);
      await repo.revertToWaiting(id);
      expect((await repo.byId(id))!.status, TaskStatus.done);
    });

    test('is allowed on the terminal instance (no rule)', () async {
      // N = 1 is a one-off; use remaining=1 so the child is terminal.
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 1, remaining: 1).encode(),
      );
      await repo.complete(id);
      final terminal = await pendingOne();
      expect(terminal.recurrence, isNull);
      await repo.complete(terminal.id);
      await repo.revertToWaiting(terminal.id);
      expect((await repo.byId(terminal.id))!.status, TaskStatus.waiting);
    });
  });

  group('duplicate', () {
    test('strips recurrence and series id (repeat-last is a one-off)', () async {
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 7).encode(),
      );
      final copyId = await repo.duplicate(id);
      final copy = await repo.byId(copyId);
      expect(copy!.recurrence, isNull);
      expect(copy.seriesId, isNull);
    });
  });

  group('stopRecurrence', () {
    test('clears the rule + series id; completion no longer spawns', () async {
      final id = await createRecurring(
        recurrence: const Recurrence(everyDays: 7).encode(),
      );
      await repo.stopRecurrence(id);

      final task = await repo.byId(id);
      expect(task!.recurrence, isNull);
      expect(task.seriesId, isNull);
      expect(task.status, TaskStatus.waiting); // task itself is untouched
      // Completing the now-one-off task spawns nothing.
      expect(await repo.complete(id), isNull);
      expect(await repo.watchPending().first, isEmpty);
    });
  });
}
