import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';

/// The dashboard's three buckets of pending tasks. Membership is by calendar day,
/// not by a 24-hour window — a task due last night is overdue this morning, not
/// "12 hours from now".
({List<Task> today, List<Task> overdue, List<Task> upcoming}) bucketPendingTasks(
  List<Task> pending,
  DateTime now,
) {
  final today = startOfDay(now);
  final windowEnd = today.add(const Duration(days: kUpcomingWindowDays));

  final todayTasks = <Task>[];
  final overdue = <Task>[];
  final upcoming = <Task>[];
  for (final task in pending) {
    final day = startOfDay(task.date.toLocal());
    if (day.isBefore(today)) {
      overdue.add(task);
    } else if (day == today) {
      todayTasks.add(task);
    } else if (!day.isAfter(windowEnd)) {
      upcoming.add(task);
    }
  }
  return (today: todayTasks, overdue: overdue, upcoming: upcoming);
}

/// How many calendar days a task is late by.
int overdueDays(DateTime date, DateTime now) =>
    startOfDay(now).difference(startOfDay(date.toLocal())).inDays;

/// Backward calendar-day label for a done task: yesterday 22:00 reads as
/// "yesterday", never "today".
String relativeDayLabel(DateTime date, DateTime now, Translations t) {
  final days = overdueDays(date, now);
  if (days <= 0) return t.common.today;
  if (days == 1) return t.common.yesterday;
  return formatDmy(date.toLocal());
}

/// Forward calendar-day label for an upcoming task: "tomorrow", else a short date.
String futureDayLabel(DateTime date, DateTime now, Translations t) {
  final days = startOfDay(date.toLocal()).difference(startOfDay(now)).inDays;
  if (days == 1) return t.tasks_list.status_tomorrow;
  return formatDm(date.toLocal());
}
