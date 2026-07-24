import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import '../../tasks/presentation/task_day_groups.dart';

/// The dashboard's three buckets of pending tasks, derived from the one task-day
/// grouping the task list uses. Tasks past the upcoming window belong to no
/// bucket — the dashboard does not show them at all.
({List<Task> today, List<Task> overdue, List<Task> upcoming}) bucketPendingTasks(
  List<Task> pending,
  DateTime now,
) {
  final todayTasks = <Task>[];
  final overdue = <Task>[];
  final upcoming = <Task>[];

  for (final task in pending) {
    switch (taskDayGroup(task.date, now)) {
      case TaskDayGroup.overdue:
        overdue.add(task);
      case TaskDayGroup.today:
        todayTasks.add(task);
      case TaskDayGroup.tomorrow || TaskDayGroup.thisWeek:
        upcoming.add(task);
      case TaskDayGroup.later:
        break;
    }
  }
  return (today: todayTasks, overdue: overdue, upcoming: upcoming);
}

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
