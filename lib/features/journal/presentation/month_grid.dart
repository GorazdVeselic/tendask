import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';

/// The day the calendar opens on when [month] comes into view: today, when it
/// falls in that month — otherwise no day is preselected.
DateTime? preselectedDay(DateTime month, DateTime now) =>
    month.year == now.year && month.month == now.month ? startOfDay(now) : null;

/// Tasks scheduled on [day], oldest first.
List<Task> tasksOnDay(List<Task> tasks, DateTime day) =>
    tasks.where((task) => isSameDay(task.date.toLocal(), day)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

/// How many tasks fall on each day-of-month of [month], and how many in total —
/// the dots under a day cell and the count above the grid.
({Map<int, int> byDay, int total}) taskCountsInMonth(
  List<Task> tasks,
  DateTime month,
) {
  final byDay = <int, int>{};
  var total = 0;

  for (final task in tasks) {
    final local = task.date.toLocal();
    if (local.year == month.year && local.month == month.month) {
      byDay[local.day] = (byDay[local.day] ?? 0) + 1;
      total++;
    }
  }
  return (byDay: byDay, total: total);
}
