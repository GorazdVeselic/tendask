import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';

/// Cells for the month grid: leading `null`s to align the 1st under the right
/// weekday, then one [DateTime] per day. [firstWeekday] is 0=Sunday..6=Saturday
/// (as in [MaterialLocalizations.firstDayOfWeekIndex]).
List<DateTime?> monthCells(DateTime month, int firstWeekday) {
  final first = DateTime(month.year, month.month);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  // DateTime.weekday: Mon=1..Sun=7 → normalize to 0=Sun..6=Sat.
  final firstCol = (first.weekday % 7 - firstWeekday + 7) % 7;
  return [
    for (var i = 0; i < firstCol; i++) null,
    for (var d = 1; d <= daysInMonth; d++) DateTime(month.year, month.month, d),
  ];
}

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
