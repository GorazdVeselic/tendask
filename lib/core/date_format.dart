// Display-only date helpers. Callers pass already-localized DateTimes
// (`.toLocal()`); storage/sync logic uses UTC via the repository.

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// The same calendar day, whatever the time of day.
bool isSameDay(DateTime a, DateTime b) => startOfDay(a) == startOfDay(b);

/// `1. 6. 2026`
String formatDmy(DateTime d) => '${d.day}. ${d.month}. ${d.year}';

/// `1. 6.` — day and month, no year (for current-year lists).
String formatDm(DateTime d) => '${d.day}. ${d.month}.';

/// Moves [time] onto [date], keeping its hour and minute — rescheduling a task
/// to another day must not silently reset the time of day it was set for.
DateTime combineDateAndTime(DateTime date, DateTime time) =>
    DateTime(date.year, date.month, date.day, time.hour, time.minute);

/// `08:05`
String formatHm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
