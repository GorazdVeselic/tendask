import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/journal/presentation/month_grid.dart';

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
  group('monthCells', () {
    test('June 2026 with Monday start: 1st is Monday → no leading nulls', () {
      // 1 June 2026 is a Monday; firstWeekday=1 (Monday).
      final cells = monthCells(DateTime(2026, 6), 1);
      expect(cells.length, 30);
      expect(cells.first, DateTime(2026, 6, 1));
      expect(cells.last, DateTime(2026, 6, 30));
    });

    test('June 2026 with Sunday start: 1st (Mon) → 1 leading null', () {
      final cells = monthCells(DateTime(2026, 6), 0);
      expect(cells.length, 31); // 1 leading null + 30 days
      expect(cells.first, isNull);
      expect(cells[1], DateTime(2026, 6, 1));
      expect(cells.last, DateTime(2026, 6, 30));
    });

    test('leading nulls align the 1st under its weekday column', () {
      // 1 Feb 2026 is a Sunday (weekday 7). Monday start → 6 leading nulls.
      final cells = monthCells(DateTime(2026, 2), 1);
      final leading = cells.takeWhile((c) => c == null).length;
      expect(leading, 6);
      expect(cells[leading], DateTime(2026, 2, 1));
    });

    test('handles leap February (29 days)', () {
      final days = monthCells(DateTime(2024, 2), 1).whereType<DateTime>();
      expect(days.length, 29);
      expect(days.last, DateTime(2024, 2, 29));
    });

    test('handles 31-day month', () {
      final days = monthCells(DateTime(2026, 1), 1).whereType<DateTime>();
      expect(days.length, 31);
    });
  });

  final now = DateTime(2026, 6, 10, 9);

  group('preselectedDay', () {
    test('the current month opens on today', () {
      expect(preselectedDay(DateTime(2026, 6), now), DateTime(2026, 6, 10));
    });

    test('another month opens with no day selected', () {
      expect(preselectedDay(DateTime(2026, 7), now), isNull);
      expect(preselectedDay(DateTime(2025, 6), now), isNull);
    });
  });

  group('tasksOnDay', () {
    test('takes the whole calendar day, oldest first', () {
      final tasks = [
        _task('evening', DateTime(2026, 6, 10, 20)),
        _task('morning', DateTime(2026, 6, 10, 6)),
        _task('next day', DateTime(2026, 6, 11, 6)),
      ];

      final onDay = tasksOnDay(tasks, DateTime(2026, 6, 10));

      expect(onDay.map((t) => t.id), ['morning', 'evening']);
    });

    test('a day with nothing scheduled is empty', () {
      expect(
        tasksOnDay([_task('t1', DateTime(2026, 6, 10))], DateTime(2026, 6, 11)),
        isEmpty,
      );
    });
  });

  group('taskCountsInMonth', () {
    test('counts per day and in total, ignoring other months', () {
      final counts = taskCountsInMonth([
        _task('a', DateTime(2026, 6, 10, 8)),
        _task('b', DateTime(2026, 6, 10, 18)),
        _task('c', DateTime(2026, 6, 12)),
        _task('other month', DateTime(2026, 7, 1)),
        _task('other year', DateTime(2025, 6, 10)),
      ], DateTime(2026, 6));

      expect(counts.byDay, {10: 2, 12: 1});
      expect(counts.total, 3);
    });

    test('an empty month counts nothing', () {
      final counts = taskCountsInMonth(const [], DateTime(2026, 6));

      expect(counts.byDay, isEmpty);
      expect(counts.total, 0);
    });
  });
}
