import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/reminder_draft.dart';
import 'package:tendask/features/tasks/task_specs.dart';

ReminderDraft _draft({
  bool custom = false,
  int offset = 60,
  ReminderUnit unit = ReminderUnit.days,
  int value = 2,
  TimeOfDay time = const TimeOfDay(hour: 18, minute: 0),
}) => ReminderDraft(
  custom: custom,
  offset: offset,
  customUnit: unit,
  customValue: value,
  time: time,
);

void main() {
  group('reminderUnitMinutes', () {
    test('minutes/hours/days map to 1/60/1440', () {
      expect(reminderUnitMinutes(ReminderUnit.minutes), 1);
      expect(reminderUnitMinutes(ReminderUnit.hours), 60);
      expect(reminderUnitMinutes(ReminderUnit.days), 1440);
    });
  });

  group('effectiveOffset', () {
    test('a preset uses its offset directly', () {
      expect(_draft(offset: 60).effectiveOffset, 60);
    });

    test('a custom offset is value × unit', () {
      expect(
        _draft(custom: true, value: 2, unit: ReminderUnit.days).effectiveOffset,
        2880,
      );
      expect(
        _draft(custom: true, value: 3, unit: ReminderUnit.hours).effectiveOffset,
        180,
      );
    });
  });

  group('isDayBased', () {
    test('preset: only offsets of a day or more carry a time', () {
      expect(_draft(offset: 1440).isDayBased, isTrue);
      expect(_draft(offset: 60).isDayBased, isFalse);
    });

    test('custom: the unit decides, regardless of the total minutes', () {
      // 48 hours = 2 days worth of minutes, but stays relative (no time).
      expect(_draft(custom: true, unit: ReminderUnit.hours, value: 48).isDayBased, isFalse);
      expect(_draft(custom: true, unit: ReminderUnit.days, value: 1).isDayBased, isTrue);
    });
  });

  group('timeText', () {
    test('pads hours and minutes to two digits', () {
      expect(_draft(time: const TimeOfDay(hour: 9, minute: 5)).timeText, '09:05');
    });
  });

  group('toSpec', () {
    test('a day-based reminder carries its time', () {
      final spec = _draft(offset: 1440, time: const TimeOfDay(hour: 8, minute: 0)).toSpec();
      expect(spec.offsetMinutes, 1440);
      expect(spec.time, '08:00');
    });

    test('a relative reminder has no time', () {
      final spec = _draft(offset: 60).toSpec();
      expect(spec.offsetMinutes, 60);
      expect(spec.time, isNull);
    });
  });

  group('canAdd', () {
    test('a blank custom value cannot be added', () {
      expect(_draft(custom: true, value: 0).canAdd(const []), isFalse);
    });

    test('a fresh reminder can be added', () {
      expect(_draft(offset: 60).canAdd(const []), isTrue);
    });

    test('an exact duplicate cannot be added again', () {
      const existing = [ReminderSpec(offsetMinutes: 60)];
      expect(_draft(offset: 60).canAdd(existing), isFalse);
    });

    test('a day-based reminder at a new time is not a duplicate', () {
      const existing = [ReminderSpec(offsetMinutes: 1440, time: '18:00')];
      final draft = _draft(offset: 1440, time: const TimeOfDay(hour: 8, minute: 0));
      expect(draft.canAdd(existing), isTrue);
    });
  });

  group('reminderOffsetTaken', () {
    test('a relative offset already added is taken (it could only repeat)', () {
      const existing = [ReminderSpec(offsetMinutes: 60)];
      expect(reminderOffsetTaken(existing, 60), isTrue);
    });

    test('an offset not yet added is free', () {
      expect(reminderOffsetTaken(const [], 60), isFalse);
    });

    test('a day-based offset stays selectable (it varies by time)', () {
      const existing = [ReminderSpec(offsetMinutes: 1440, time: '18:00')];
      expect(reminderOffsetTaken(existing, 1440), isFalse);
    });
  });
}
