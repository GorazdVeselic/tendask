import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/tasks/presentation/entry/entry_defaults.dart';
import 'package:tendask/features/tasks/presentation/entry/entry_flow.dart';

void main() {
  group('activeSteps', () {
    test('a done task skips the reminder step', () {
      final steps = activeSteps(
        status: TaskStatus.done,
        consumesSupplies: false,
      );

      expect(steps, isNot(contains(EntryStep.reminder)));
      expect(steps, [
        EntryStep.type,
        EntryStep.subject,
        EntryStep.when,
        EntryStep.review,
      ]);
    });

    test('a planned task gets the reminder step, before review', () {
      final steps = activeSteps(
        status: TaskStatus.waiting,
        consumesSupplies: false,
      );

      expect(steps, [
        EntryStep.type,
        EntryStep.subject,
        EntryStep.when,
        EntryStep.reminder,
        EntryStep.review,
      ]);
    });

    test('a type that draws no stock never gets the supplies step', () {
      final steps = activeSteps(
        status: TaskStatus.waiting,
        consumesSupplies: false,
      );

      expect(steps, isNot(contains(EntryStep.supplies)));
    });

    test('a consuming type gets the supplies step only while the flag is on', () {
      final steps = activeSteps(
        status: TaskStatus.done,
        consumesSupplies: true,
      );

      expect(steps.contains(EntryStep.supplies), kSuppliesEnabled);
    });
  });

  group('nextStep / previousStep', () {
    final planned = activeSteps(
      status: TaskStatus.waiting,
      consumesSupplies: false,
    );
    final logged = activeSteps(
      status: TaskStatus.done,
      consumesSupplies: false,
    );

    test('a done task jumps from "when" straight to review', () {
      expect(nextStep(EntryStep.when, logged), EntryStep.review);
    });

    test('a planned task passes through the reminder step', () {
      expect(nextStep(EntryStep.when, planned), EntryStep.reminder);
      expect(nextStep(EntryStep.reminder, planned), EntryStep.review);
    });

    test('review is the last step — nothing follows it', () {
      expect(nextStep(EntryStep.review, planned), isNull);
    });

    test('back from the first step leaves the wizard (null)', () {
      expect(previousStep(EntryStep.type, planned), isNull);
    });

    test('back skips the steps that are not part of the flow', () {
      expect(previousStep(EntryStep.review, logged), EntryStep.when);
      expect(previousStep(EntryStep.review, planned), EntryStep.reminder);
    });
  });

  group('canLeaveStep', () {
    bool can(EntryStep step, {String? typeId, bool subjects = false, TaskStatus status = TaskStatus.done, bool recurrenceValid = true}) =>
        canLeaveStep(
          step,
          taskTypeId: typeId,
          hasSubjects: subjects,
          status: status,
          recurrenceValid: recurrenceValid,
        );

    test('the type step needs a picked type', () {
      expect(can(EntryStep.type), isFalse);
      expect(can(EntryStep.type, typeId: 'water'), isTrue);
    });

    test('the subject step needs at least one plant or area', () {
      expect(can(EntryStep.subject), isFalse);
      expect(can(EntryStep.subject, subjects: true), isTrue);
    });

    test('an invalid recurrence only blocks a planned task', () {
      expect(
        can(EntryStep.when, status: TaskStatus.waiting, recurrenceValid: false),
        isFalse,
      );
      expect(
        can(EntryStep.when, status: TaskStatus.done, recurrenceValid: false),
        isTrue,
      );
    });

    test('the optional steps and review never block', () {
      expect(can(EntryStep.reminder), isTrue);
      expect(can(EntryStep.supplies), isTrue);
      expect(can(EntryStep.review), isTrue);
    });
  });

  group('nextFullHour', () {
    test('rounds up to the coming hour', () {
      expect(
        nextFullHour(DateTime(2026, 6, 1, 14, 20)),
        DateTime(2026, 6, 1, 15),
      );
    });

    test('late in the evening it rolls into tomorrow', () {
      expect(
        nextFullHour(DateTime(2026, 6, 1, 23, 40)),
        DateTime(2026, 6, 2),
      );
    });
  });

  group('statusFromDate', () {
    final now = DateTime(2026, 6, 1, 12);

    test('a future date is planned', () {
      expect(statusFromDate(DateTime(2026, 6, 1, 13), now), TaskStatus.waiting);
    });

    test('the present moment is logged as done', () {
      expect(statusFromDate(now, now), TaskStatus.done);
    });

    test('a past date is logged as done', () {
      expect(statusFromDate(DateTime(2026, 5, 30), now), TaskStatus.done);
    });
  });

  group('shouldSeedReminder', () {
    bool seed({
      bool didSeed = false,
      TaskStatus status = TaskStatus.waiting,
      bool hasReminders = false,
      bool enabled = true,
    }) => shouldSeedReminder(
      didSeed: didSeed,
      status: status,
      hasReminders: hasReminders,
      remindersEnabled: enabled,
    );

    test('a planned task with no reminders gets one', () {
      expect(seed(), isTrue);
    });

    test('never seeds twice — a removed default must not come back', () {
      expect(seed(didSeed: true), isFalse);
    });

    test('a done task gets none', () {
      expect(seed(status: TaskStatus.done), isFalse);
    });

    test('a task that already has a reminder gets none', () {
      expect(seed(hasReminders: true), isFalse);
    });

    test('none when the user turned task reminders off', () {
      expect(seed(enabled: false), isFalse);
    });
  });
}
