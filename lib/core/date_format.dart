// Display-only date helpers. Callers pass already-localized DateTimes
// (`.toLocal()`); storage/sync logic uses UTC via the repository.

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// `1. 6. 2026`
String formatDmy(DateTime d) => '${d.day}. ${d.month}. ${d.year}';

/// `08:05`
String formatHm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
