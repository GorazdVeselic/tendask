import '../../../core/config.dart';
import '../../../core/date_format.dart';
import '../../tasks/data/tasks_repository.dart';

/// Local wall-clock time a reminder should fire, from the task's local date.
///
/// Day-based offsets (>= [kMinutesPerDay]) carrying a time-of-day fire N whole
/// days before the task date at that time (e.g. "1 day before at 18:00"). Sub-day
/// offsets (and day-based without a time) fire [offsetMinutes] before the task's
/// own time. Pure — the caller compares against a [Clock] to skip past times.
DateTime reminderFireTime({
  required DateTime taskDateLocal,
  required int offsetMinutes,
  String? reminderTime,
}) {
  if (offsetMinutes >= kMinutesPerDay && reminderTime != null) {
    final base = startOfDay(
      taskDateLocal,
    ).subtract(Duration(days: offsetMinutes ~/ kMinutesPerDay));
    final (h, m) = _parseHm(reminderTime);
    return DateTime(base.year, base.month, base.day, h, m);
  }
  return taskDateLocal.subtract(Duration(minutes: offsetMinutes));
}

/// Local days that already carry a future task reminder, so a gentle hint can
/// skip them (FR-16 §3.5). One join query (no N+1), then [reminderFireTime] —
/// the same fire-time logic the reminder coordinator schedules with.
Future<Set<DateTime>> futureTaskReminderDays(
  TasksRepository repo,
  DateTime nowLocal,
) async {
  final days = <DateTime>{};
  for (final input in await repo.reminderScheduleInputs()) {
    final fire = reminderFireTime(
      taskDateLocal: input.taskDate.toLocal(),
      offsetMinutes: input.offsetMinutes,
      reminderTime: input.reminderTime,
    );
    if (fire.isAfter(nowLocal)) days.add(startOfDay(fire));
  }
  return days;
}

/// Stable positive 31-bit OS notification id from a reminder's UUID, so a
/// reminder can be scheduled and later cancelled without a schema change.
int reminderNotificationId(String reminderId) =>
    reminderId.hashCode & 0x7fffffff;

(int, int) _parseHm(String hm) {
  final parts = hm.split(':');
  return (int.parse(parts[0]), int.parse(parts[1]));
}
