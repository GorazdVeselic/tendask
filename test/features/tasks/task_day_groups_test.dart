import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/tasks/presentation/task_day_groups.dart';
import 'package:tendask/i18n/translations.g.dart';

Task _task(String id, DateTime date) => Task(
  id: id,
  userId: 'u1',
  taskTypeId: 'water',
  date: date,
  status: TaskStatus.waiting,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  // Mid-morning "now" — grouping must split by calendar day, not by a 24h window
  // around this moment.
  final now = DateTime(2026, 6, 10, 9);

  group('taskDayGroup', () {
    test('last night late is overdue this morning, not "12 hours from now"', () {
      expect(
        taskDayGroup(DateTime(2026, 6, 9, 22), now),
        TaskDayGroup.overdue,
      );
    });

    test('earlier today is still today — not overdue yet', () {
      expect(taskDayGroup(DateTime(2026, 6, 10, 7), now), TaskDayGroup.today);
    });

    test('later today is today', () {
      expect(taskDayGroup(DateTime(2026, 6, 10, 18), now), TaskDayGroup.today);
    });

    test('tomorrow is its own group, not this week', () {
      expect(
        taskDayGroup(DateTime(2026, 6, 11, 6), now),
        TaskDayGroup.tomorrow,
      );
    });

    test('two days out is this week', () {
      expect(taskDayGroup(DateTime(2026, 6, 12), now), TaskDayGroup.thisWeek);
    });

    test('the last day of the window is still this week', () {
      expect(
        taskDayGroup(DateTime(2026, 6, 10 + kUpcomingWindowDays, 23), now),
        TaskDayGroup.thisWeek,
      );
    });

    test('a day past the window is later', () {
      expect(
        taskDayGroup(DateTime(2026, 6, 11 + kUpcomingWindowDays), now),
        TaskDayGroup.later,
      );
    });
  });

  group('buildTaskListItems', () {
    test('empty input yields no items — not a lone heading', () {
      expect(buildTaskListItems(const [], now), isEmpty);
    });

    test('an empty group gets no heading', () {
      final items = buildTaskListItems([
        _task('t1', DateTime(2026, 6, 10, 12)),
      ], now);

      expect(items, hasLength(2));
      expect((items[0] as TaskSectionItem).group, TaskDayGroup.today);
      expect((items[1] as TaskRowItem).task.id, 't1');
    });

    test('sections come in day order, each with its tasks under it', () {
      final items = buildTaskListItems([
        _task('later', DateTime(2026, 6, 30)),
        _task('today', DateTime(2026, 6, 10, 12)),
        _task('late', DateTime(2026, 6, 8)),
        _task('tomorrow', DateTime(2026, 6, 11)),
      ], now);

      final headings = items
          .whereType<TaskSectionItem>()
          .map((s) => s.group)
          .toList();
      expect(headings, [
        TaskDayGroup.overdue,
        TaskDayGroup.today,
        TaskDayGroup.tomorrow,
        TaskDayGroup.later,
      ]);

      final rows = items.whereType<TaskRowItem>().toList();
      expect(rows.map((r) => r.task.id), ['late', 'today', 'tomorrow', 'later']);
      expect(rows.first.group, TaskDayGroup.overdue);
    });

    test('tasks keep their input order within a group', () {
      final items = buildTaskListItems([
        _task('a', DateTime(2026, 6, 10, 18)),
        _task('b', DateTime(2026, 6, 10, 7)),
      ], now);

      expect(
        items.whereType<TaskRowItem>().map((r) => r.task.id),
        ['a', 'b'],
      );
    });
  });

  group('overdueDays', () {
    test('counts calendar days, not elapsed hours', () {
      // 11 hours earlier, but a day earlier on the calendar → 1 day late.
      expect(overdueDays(DateTime(2026, 6, 9, 22), now), 1);
    });

    test('same day is zero', () {
      expect(overdueDays(DateTime(2026, 6, 10, 1), now), 0);
    });
  });

  group('taskStatusText', () {
    test('overdue reads as the number of days late', () {
      expect(
        taskStatusText(
          TaskDayGroup.overdue,
          DateTime(2026, 6, 8),
          now,
          t,
        ),
        t.tasks_list.overdue_days(n: 2),
      );
    });

    test('today and tomorrow read as relative days', () {
      expect(
        taskStatusText(TaskDayGroup.today, DateTime(2026, 6, 10), now, t),
        t.tasks_list.status_today,
      );
      expect(
        taskStatusText(TaskDayGroup.tomorrow, DateTime(2026, 6, 11), now, t),
        t.tasks_list.status_tomorrow,
      );
    });

    test('further out reads as a short day and month', () {
      expect(
        taskStatusText(TaskDayGroup.thisWeek, DateTime(2026, 6, 14), now, t),
        '14. 6.',
      );
      expect(
        taskStatusText(TaskDayGroup.later, DateTime(2026, 6, 30), now, t),
        '30. 6.',
      );
    });
  });
}
