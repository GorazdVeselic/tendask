import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';

/// The calendar-day section a pending task belongs to. Membership is by calendar
/// day, not by a 24-hour window — a task due last night is overdue this morning,
/// not "12 hours from now".
enum TaskDayGroup { overdue, today, tomorrow, thisWeek, later }

/// The section [date] falls in, relative to [now]. `thisWeek` reaches up to and
/// including [kUpcomingWindowDays] days out — the same boundary the dashboard's
/// upcoming bar uses, so a task cannot sit in one screen's week and the other's
/// "later".
TaskDayGroup taskDayGroup(DateTime date, DateTime now) {
  final today = startOfDay(now);
  final day = startOfDay(date.toLocal());

  if (day.isBefore(today)) return TaskDayGroup.overdue;
  if (day == today) return TaskDayGroup.today;
  if (day == today.add(const Duration(days: 1))) return TaskDayGroup.tomorrow;
  if (!day.isAfter(today.add(const Duration(days: kUpcomingWindowDays)))) {
    return TaskDayGroup.thisWeek;
  }
  return TaskDayGroup.later;
}

/// How many calendar days a task is late by.
int overdueDays(DateTime date, DateTime now) =>
    startOfDay(now).difference(startOfDay(date.toLocal())).inDays;

/// One entry of the task list: a section heading, or a task row under it.
sealed class TaskListItem {
  const TaskListItem();
}

class TaskSectionItem extends TaskListItem {
  const TaskSectionItem(this.group);

  final TaskDayGroup group;
}

class TaskRowItem extends TaskListItem {
  const TaskRowItem(this.task, this.group);

  final Task task;
  final TaskDayGroup group;
}

/// Flattens tasks into headings + rows in [TaskDayGroup] order. An empty group
/// gets no heading.
List<TaskListItem> buildTaskListItems(List<Task> tasks, DateTime now) {
  final grouped = <TaskDayGroup, List<Task>>{
    for (final group in TaskDayGroup.values) group: [],
  };
  for (final task in tasks) {
    grouped[taskDayGroup(task.date, now)]!.add(task);
  }

  final items = <TaskListItem>[];
  for (final group in TaskDayGroup.values) {
    final tasksInGroup = grouped[group]!;
    if (tasksInGroup.isEmpty) continue;
    items.add(TaskSectionItem(group));
    items.addAll(tasksInGroup.map((task) => TaskRowItem(task, group)));
  }
  return items;
}

/// Section heading of a group.
String taskGroupLabel(TaskDayGroup group, Translations t) => switch (group) {
  TaskDayGroup.overdue => t.tasks_list.section_overdue,
  TaskDayGroup.today => t.tasks_list.section_today,
  TaskDayGroup.tomorrow => t.tasks_list.section_tomorrow,
  TaskDayGroup.thisWeek => t.tasks_list.section_this_week,
  TaskDayGroup.later => t.tasks_list.section_later,
};

/// Trailing status text of a task row: how late it is, a relative day, or a
/// short date once it is further out than tomorrow.
String taskStatusText(
  TaskDayGroup group,
  DateTime date,
  DateTime now,
  Translations t,
) => switch (group) {
  TaskDayGroup.overdue => t.tasks_list.overdue_days(
    n: overdueDays(date, now),
  ),
  TaskDayGroup.today => t.tasks_list.status_today,
  TaskDayGroup.tomorrow => t.tasks_list.status_tomorrow,
  TaskDayGroup.thisWeek || TaskDayGroup.later => formatDm(date.toLocal()),
};
