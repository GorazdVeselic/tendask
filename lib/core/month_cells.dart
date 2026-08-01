/// Cells for a month grid: leading `null`s to align the 1st under the right
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
