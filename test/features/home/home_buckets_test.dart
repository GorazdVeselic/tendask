import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/home/presentation/home_buckets.dart';
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

  // Mid-morning "now" — the buckets must split by calendar day, not by a 24h
  // window around this moment.
  final now = DateTime(2026, 6, 10, 9);

  group('bucketPendingTasks', () {
    test('a task later today lands in today, not in upcoming', () {
      final buckets = bucketPendingTasks([
        _task('t1', DateTime(2026, 6, 10, 18)),
      ], now);

      expect(buckets.today.single.id, 't1');
      expect(buckets.upcoming, isEmpty);
      expect(buckets.overdue, isEmpty);
    });

    test('a task earlier today is still today — not overdue yet', () {
      final buckets = bucketPendingTasks([
        _task('t1', DateTime(2026, 6, 10, 7)),
      ], now);

      expect(buckets.today.single.id, 't1');
      expect(buckets.overdue, isEmpty);
    });

    test('last night late is overdue this morning (calendar day, not 24h)', () {
      final buckets = bucketPendingTasks([
        _task('t1', DateTime(2026, 6, 9, 22)),
      ], now);

      expect(buckets.overdue.single.id, 't1');
      expect(buckets.today, isEmpty);
    });

    test('tomorrow is upcoming', () {
      final buckets = bucketPendingTasks([
        _task('t1', DateTime(2026, 6, 11, 6)),
      ], now);

      expect(buckets.upcoming.single.id, 't1');
    });

    test('the last day of the window is still upcoming', () {
      final buckets = bucketPendingTasks([
        _task('t1', DateTime(2026, 6, 10 + kUpcomingWindowDays, 23)),
      ], now);

      expect(buckets.upcoming.single.id, 't1');
    });

    test('a day past the window falls out of all three buckets', () {
      final buckets = bucketPendingTasks([
        _task('t1', DateTime(2026, 6, 11 + kUpcomingWindowDays)),
      ], now);

      expect(buckets.today, isEmpty);
      expect(buckets.upcoming, isEmpty);
      expect(buckets.overdue, isEmpty);
    });

    test('a mixed list splits into all three buckets', () {
      final buckets = bucketPendingTasks([
        _task('late', DateTime(2026, 6, 8)),
        _task('now', DateTime(2026, 6, 10, 12)),
        _task('soon', DateTime(2026, 6, 12)),
      ], now);

      expect(buckets.overdue.single.id, 'late');
      expect(buckets.today.single.id, 'now');
      expect(buckets.upcoming.single.id, 'soon');
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

  group('relativeDayLabel', () {
    test('yesterday at 22:00 reads as yesterday, never today', () {
      expect(relativeDayLabel(DateTime(2026, 6, 9, 22), now, t), t.common.yesterday);
    });

    test('today reads as today', () {
      expect(relativeDayLabel(DateTime(2026, 6, 10, 1), now, t), t.common.today);
    });

    test('older than yesterday falls back to the full date', () {
      expect(relativeDayLabel(DateTime(2026, 6, 1), now, t), '1. 6. 2026');
    });
  });

  group('futureDayLabel', () {
    test('tomorrow reads as tomorrow', () {
      expect(
        futureDayLabel(DateTime(2026, 6, 11, 6), now, t),
        t.tasks_list.status_tomorrow,
      );
    });

    test('further out reads as a short day and month', () {
      expect(futureDayLabel(DateTime(2026, 6, 14), now, t), '14. 6.');
    });
  });
}
