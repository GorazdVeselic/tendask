import '../../../core/date_format.dart';

/// Which "when" segment a note is filed under. Custom carries an explicit date.
enum NoteDateOption { today, yesterday, custom }

/// The segment a stored note [date] maps to, relative to [now]. Pure: [now] is
/// injected so the today/yesterday boundary is testable.
NoteDateOption noteDateOption(DateTime date, DateTime now) {
  final today = startOfDay(now);
  final day = startOfDay(date);
  if (day == today) return NoteDateOption.today;
  if (day == today.subtract(const Duration(days: 1))) {
    return NoteDateOption.yesterday;
  }
  return NoteDateOption.custom;
}

/// The concrete date a note is saved with, given the chosen [option] and any
/// [customDate], relative to [now].
DateTime noteSelectedDate(
  NoteDateOption option,
  DateTime? customDate,
  DateTime now,
) => switch (option) {
  NoteDateOption.today => now,
  NoteDateOption.yesterday => now.subtract(const Duration(days: 1)),
  NoteDateOption.custom => customDate ?? now,
};
