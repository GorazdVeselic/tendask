import '../../../core/config.dart';
import '../../../core/date_format.dart';
import '../../../core/notifications/notification_settings.dart';

/// Local wall-clock fire times for the re-engagement journal nudge (FR-16).
///
/// Each is [dayOffsets] whole days after [fromLocal] at [hour]:00. The caller
/// recomputes this from "now" on every app open / task or note write, so an
/// active user's nudges are forever pushed forward and never fire; only after
/// the user goes quiet does the (decaying) chain fire, then fall silent.
///
/// A day already carrying a task reminder ([taskReminderDays], each a
/// `startOfDay` local date) is skipped to the next free day, so the nudge never
/// doubles up with an explicit reminder (FR-16 §3.5). Returned times are in the
/// same order as [dayOffsets] and strictly increasing by day.
List<DateTime> journalNudgeFireTimes({
  required DateTime fromLocal,
  required List<int> dayOffsets,
  required int hour,
  Set<DateTime> taskReminderDays = const {},
}) {
  final today = startOfDay(fromLocal);
  final times = <DateTime>[];
  var minDay = today;
  for (final offset in dayOffsets) {
    var day = addDays(today, offset);
    // Keep the chain strictly increasing even if a collision shift from the
    // previous step pushed past this offset's nominal day.
    if (!day.isAfter(minDay)) {
      day = addDays(minDay, 1);
    }
    while (taskReminderDays.contains(day)) {
      day = addDays(day, 1);
    }
    times.add(DateTime(day.year, day.month, day.day, hour));
    minDay = day;
  }
  return times;
}

/// Local days the currently armed nudge chain occupies, empty when the user
/// opted out. The junior moon hint (FR-19 T4b) yields to these days — one
/// gentle hint per day, and the nudge is the senior of the two.
Set<DateTime> journalNudgeDays({
  required DateTime fromLocal,
  required NotificationSettings settings,
  Set<DateTime> taskReminderDays = const {},
}) {
  if (!settings.journalNudgeEnabled) return const {};
  // kJournalNudgeHour is outside quiet hours, so the scheduled day is the
  // computed day (no hint_rules shift to mirror here).
  return journalNudgeFireTimes(
    fromLocal: fromLocal,
    dayOffsets: kJournalNudgeDayOffsets,
    hour: kJournalNudgeHour,
    taskReminderDays: taskReminderDays,
  ).map(startOfDay).toSet();
}
