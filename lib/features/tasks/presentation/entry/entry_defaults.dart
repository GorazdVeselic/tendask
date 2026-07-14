import '../../../../core/task_status.dart';

/// The date a new task opens on: the next full hour, so a task entered at 14:20
/// is planned for 15:00 (and at 23:xx rolls into tomorrow).
DateTime nextFullHour(DateTime now) =>
    DateTime(now.year, now.month, now.day, now.hour + 1);

/// Anything in the future is planned (waiting); now or past is logged as done.
TaskStatus statusFromDate(DateTime date, DateTime now) =>
    date.isAfter(now) ? TaskStatus.waiting : TaskStatus.done;

/// Whether the one default reminder (T7) should still be seeded. It is offered
/// once per entry — the sentinel sticks even after the user removes it, so a
/// removed reminder never silently comes back.
bool shouldSeedReminder({
  required bool didSeed,
  required TaskStatus status,
  required bool hasReminders,
  required bool remindersEnabled,
}) =>
    !didSeed &&
    status == TaskStatus.waiting &&
    !hasReminders &&
    remindersEnabled;
