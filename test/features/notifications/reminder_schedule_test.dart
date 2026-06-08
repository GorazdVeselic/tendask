import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/notifications/application/reminder_schedule.dart';

void main() {
  // Task on 10 Jun 2026 at 09:00 (local wall-clock).
  final taskDate = DateTime(2026, 6, 10, 9, 0);

  group('reminderFireTime', () {
    test('day-based offset with time fires N days before at that time', () {
      expect(
        reminderFireTime(
          taskDateLocal: taskDate,
          offsetMinutes: 1440,
          reminderTime: '18:00',
        ),
        DateTime(2026, 6, 9, 18, 0),
      );
      expect(
        reminderFireTime(
          taskDateLocal: taskDate,
          offsetMinutes: 2880,
          reminderTime: '07:30',
        ),
        DateTime(2026, 6, 8, 7, 30),
      );
    });

    test('sub-day offsets fire before the task own time', () {
      expect(
        reminderFireTime(taskDateLocal: taskDate, offsetMinutes: 0),
        taskDate, // at event time
      );
      expect(
        reminderFireTime(taskDateLocal: taskDate, offsetMinutes: 10),
        DateTime(2026, 6, 10, 8, 50),
      );
      expect(
        reminderFireTime(taskDateLocal: taskDate, offsetMinutes: 60),
        DateTime(2026, 6, 10, 8, 0),
      );
    });

    test('day-based offset without a time keeps the task own time', () {
      expect(
        reminderFireTime(taskDateLocal: taskDate, offsetMinutes: 1440),
        DateTime(2026, 6, 9, 9, 0),
      );
    });

    test('crosses a month boundary correctly', () {
      expect(
        reminderFireTime(
          taskDateLocal: DateTime(2026, 7, 1, 8, 0),
          offsetMinutes: 1440,
          reminderTime: '20:00',
        ),
        DateTime(2026, 6, 30, 20, 0),
      );
    });
  });

  group('reminderNotificationId', () {
    test('is deterministic and positive 31-bit', () {
      const uuid = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';
      final id = reminderNotificationId(uuid);
      expect(id, reminderNotificationId(uuid));
      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    });

    test('different reminders map to different ids', () {
      expect(
        reminderNotificationId('3f2504e0-4f89-41d3-9a0c-0305e82c3301'),
        isNot(reminderNotificationId('a1b2c3d4-0000-1111-2222-333344445555')),
      );
    });
  });
}
