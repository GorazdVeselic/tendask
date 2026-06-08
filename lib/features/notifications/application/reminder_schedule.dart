import '../../../core/date_format.dart';

/// Local wall-clock time a reminder should fire, from the task's local date.
///
/// Day-based offsets (>= 1440 min) carrying a time-of-day fire N whole days
/// before the task date at that time (e.g. "1 day before at 18:00"). Sub-day
/// offsets (and day-based without a time) fire [offsetMinutes] before the task's
/// own time. Pure — the caller compares against a [Clock] to skip past times.
DateTime reminderFireTime({
  required DateTime taskDateLocal,
  required int offsetMinutes,
  String? reminderTime,
}) {
  if (offsetMinutes >= 1440 && reminderTime != null) {
    final base = startOfDay(
      taskDateLocal,
    ).subtract(Duration(days: offsetMinutes ~/ 1440));
    final (h, m) = _parseHm(reminderTime);
    return DateTime(base.year, base.month, base.day, h, m);
  }
  return taskDateLocal.subtract(Duration(minutes: offsetMinutes));
}

/// Stable positive 31-bit OS notification id from a reminder's UUID, so a
/// reminder can be scheduled and later cancelled without a schema change.
int reminderNotificationId(String reminderId) =>
    reminderId.hashCode & 0x7fffffff;

(int, int) _parseHm(String hm) {
  final parts = hm.split(':');
  return (int.parse(parts[0]), int.parse(parts[1]));
}
