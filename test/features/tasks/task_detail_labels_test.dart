import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/supply_category.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/tasks/presentation/task_detail_labels.dart';
import 'package:tendask/i18n/translations.g.dart';

Supply _supply(String id, String name, String unit) => Supply(
  id: id,
  userId: 'u1',
  name: name,
  unit: unit,
  category: SupplyCategory.other,
  quantity: 10,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

TaskSupply _taskSupply(String supplyId, double amount) => TaskSupply(
  id: 'ts-$supplyId',
  taskId: 't1',
  supplyId: supplyId,
  amount: amount,
  applied: true,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

TaskReminder _reminder(int offset, {String? time}) => TaskReminder(
  id: 'r$offset',
  taskId: 't1',
  offset: offset,
  reminderTime: time,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

Task _task(TaskStatus status, DateTime date) => Task(
  id: 't1',
  userId: 'u1',
  taskTypeId: 'water',
  date: date,
  status: status,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('taskSuppliesLabel', () {
    test('no supplies → null (the card then shows "none")', () {
      expect(taskSuppliesLabel(const [], const {}), isNull);
    });

    test('whole amounts drop the trailing .0, fractions keep it', () {
      final label = taskSuppliesLabel(
        [_taskSupply('urea', 1), _taskSupply('npk', 0.5)],
        {'urea': _supply('urea', 'Urea', 'kg'), 'npk': _supply('npk', 'NPK', 'kg')},
      );

      expect(label, 'Urea 1kg, NPK 0.5kg');
    });

    test('a supply missing from the catalog falls back to its id', () {
      final label = taskSuppliesLabel([_taskSupply('ghost', 2)], const {});
      expect(label, 'ghost 2');
    });
  });

  group('taskRemindersLabel', () {
    test('no reminders → null', () {
      expect(taskRemindersLabel(const [], t), isNull);
    });

    test('a day-based reminder carries its time of day', () {
      expect(
        taskRemindersLabel([_reminder(1440, time: '18:00')], t),
        '${t.entry.rem_1day} ${t.entry.rem_at(t: '18:00')}',
      );
    });

    test('an hour-based reminder ignores a time of day', () {
      expect(taskRemindersLabel([_reminder(60, time: '18:00')], t), t.entry.rem_1hour);
    });

    test('several reminders join with a comma', () {
      final label = taskRemindersLabel(
        [_reminder(1440, time: '18:00'), _reminder(60)],
        t,
      );
      expect(label, contains(', '));
      expect(label, endsWith(t.entry.rem_1hour));
    });
  });

  group('statusPillLabel', () {
    test('a waiting task reads as planned, with its date and time', () {
      final label = statusPillLabel(
        _task(TaskStatus.waiting, DateTime(2026, 6, 1, 8, 5)),
        t,
      );

      expect(label, contains(t.task_detail.badge_waiting));
      expect(label, contains('1. 6. 2026'));
      expect(label, contains('08:05'));
    });

    test('a done task reads as done', () {
      final label = statusPillLabel(
        _task(TaskStatus.done, DateTime(2026, 6, 1, 8, 5)),
        t,
      );

      expect(label, contains(t.task_detail.badge_done));
      expect(label, isNot(contains(t.task_detail.badge_waiting)));
    });
  });
}
