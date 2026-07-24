import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/supplies/data/supply_spec.dart';
import 'package:tendask/features/tasks/data/recurrence.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/features/tasks/presentation/entry/entry_save_spec.dart';
import 'package:tendask/features/tasks/yield_unit.dart';

TaskType _type(
  String id, {
  String category = 'care',
  bool consumesSupplies = false,
}) => TaskType(
  id: id,
  labels: '{"sl":"Zalivanje","en":"Watering"}',
  icon: '💧',
  category: category,
  requiresSubject: false,
  weatherSensitive: false,
  consumesSupplies: consumesSupplies,
  seasonal: true,
);

final _harvest = _type('harvest', category: 'harvest');
final _consuming = _type('fertilize', consumesSupplies: true);

const _reminders = [ReminderSpec(offsetMinutes: 1440, time: '18:00')];
const _supplies = [SupplySpec(supplyId: 'urea', amount: 1)];
const _recurrence = Recurrence(everyDays: 7);

EntrySaveSpec _resolve({
  TaskType? type,
  bool isEdit = false,
  TaskStatus status = TaskStatus.waiting,
  double? yieldAmount,
  YieldUnit? yieldUnit,
}) => resolveSave(
  type: type,
  isEdit: isEdit,
  status: status,
  reminders: _reminders,
  recurrence: _recurrence,
  supplies: _supplies,
  yieldAmount: yieldAmount,
  yieldUnit: yieldUnit,
);

void main() {
  group('reminders and recurrence', () {
    test('a planned task keeps both', () {
      final spec = _resolve(type: _type('water'));

      expect(spec.reminders, _reminders);
      expect(spec.recurrence, _recurrence);
    });

    test('a task logged as done keeps neither — they would never fire', () {
      final spec = _resolve(type: _type('water'), status: TaskStatus.done);

      expect(spec.reminders, isEmpty);
      expect(spec.recurrence, isNull);
    });
  });

  group('supplies', () {
    test('a known non-consuming type books nothing', () {
      final spec = _resolve(type: _type('water'));

      expect(spec.supplies, isEmpty);
    });

    test('a consuming type books its supplies only while the flag is on', () {
      final spec = _resolve(type: _consuming);

      expect(spec.supplies.isNotEmpty, kSuppliesEnabled);
    });

    test('create with an unresolved type books nothing (nothing is booked yet)', () {
      final spec = _resolve(type: null);

      expect(spec.supplies, isEmpty);
    });

    test('edit with an unresolved type keeps the buffer — booked stock stays', () {
      final spec = _resolve(type: null, isEdit: true);

      expect(spec.supplies, _supplies);
    });
  });

  group('yield', () {
    test('logging a done harvest records the yield', () {
      final spec = _resolve(
        type: _harvest,
        status: TaskStatus.done,
        yieldAmount: 2.5,
        yieldUnit: YieldUnit.kg,
      );

      expect(spec.yieldAmount, 2.5);
      expect(spec.yieldUnit, YieldUnit.kg);
      expect(spec.typeRecordsYield, isTrue);
    });

    test('a planned harvest records none — there is nothing to weigh yet', () {
      final spec = _resolve(
        type: _harvest,
        yieldAmount: 2.5,
        yieldUnit: YieldUnit.kg,
      );

      expect(spec.yieldAmount, isNull);
      expect(spec.yieldUnit, isNull);
    });

    test('a done non-harvest type records none', () {
      final spec = _resolve(
        type: _type('water'),
        status: TaskStatus.done,
        yieldAmount: 2.5,
        yieldUnit: YieldUnit.kg,
      );

      expect(spec.yieldAmount, isNull);
    });

    test('editing away from harvest drops the recorded yield', () {
      final spec = _resolve(
        type: _type('water'),
        isEdit: true,
        status: TaskStatus.done,
      );

      expect(spec.typeRecordsYield, isFalse);
    });

    test('an unresolved type preserves the yield — only a known type clears it', () {
      final spec = _resolve(type: null, isEdit: true, status: TaskStatus.done);

      expect(spec.typeRecordsYield, isTrue);
    });
  });
}
