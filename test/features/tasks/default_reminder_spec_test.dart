import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/reminder_step.dart';

void main() {
  // A planned task on 10 Jun 2026 at 09:00; "now" well before it.
  final taskDate = DateTime(2026, 6, 10, 9, 0);
  final now = DateTime(2026, 6, 1, 12, 0);

  group('defaultReminderSpec', () {
    test('at-event offset (0) → at-event reminder, no time', () {
      final spec = defaultReminderSpec(
        offsetMinutes: 0,
        taskDateLocal: taskDate,
        nowLocal: now,
      );
      expect(spec.offsetMinutes, 0);
      expect(spec.time, isNull);
    });

    test('sub-day offset keeps the offset and carries no time', () {
      final spec = defaultReminderSpec(
        offsetMinutes: 60,
        taskDateLocal: taskDate,
        nowLocal: now,
      );
      expect(spec.offsetMinutes, 60);
      expect(spec.time, isNull);
    });

    test('day-based offset firing in the future keeps offset + default time', () {
      final spec = defaultReminderSpec(
        offsetMinutes: 1440,
        taskDateLocal: taskDate,
        nowLocal: now,
      );
      expect(spec.offsetMinutes, 1440);
      expect(spec.time, '18:00');
    });

    test('day-based offset that would fire in the past falls back to at-event', () {
      // Task tomorrow 09:00; "now" is today 20:00, so "1 day before at 18:00"
      // (today 18:00) is already past → seed must fall back to at-event.
      final near = DateTime(2026, 6, 2, 9, 0);
      final lateNow = DateTime(2026, 6, 1, 20, 0);
      final spec = defaultReminderSpec(
        offsetMinutes: 1440,
        taskDateLocal: near,
        nowLocal: lateNow,
      );
      expect(spec.offsetMinutes, 0);
      expect(spec.time, isNull);
    });
  });
}
