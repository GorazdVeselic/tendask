import '../config.dart';
import '../date_format.dart';
import 'notification_settings.dart';

/// Anti-annoyance rules for *gentle hints* — notifications the app decides to
/// post on its own (the moon "good day" hint, the journal nudge). They never
/// apply to explicit task reminders: a reminder the user set themselves is not
/// an interruption (koncept §"Vodenje proti motečnosti").
///
/// Both rules are user toggles on screen 22, persisted since M8 but with no
/// consumer until the moon hint (FR-19 T4b).

/// Whether [local] falls inside the quiet-hours night window. The window wraps
/// past midnight ([kQuietHoursStartHour] > [kQuietHoursEndHour]).
bool inQuietHours(DateTime local) =>
    local.hour >= kQuietHoursStartHour || local.hour < kQuietHoursEndHour;

/// Local wall-clock time to post a gentle hint wanted at [desiredLocal], or
/// null when the frequency cap has already spent that day.
///
/// Quiet hours *move* a hint to the end of the window, they never drop it
/// (FR-16 §3) — so a night-time hint arrives in the morning instead of waking
/// the user. The cap allows one hint per local day: [otherHintDays] are the
/// `startOfDay` days that already carry one, and it is evaluated on the shifted
/// day. Note that a shift past midnight can land on a day the caller excluded
/// for its own reasons (e.g. task reminder days) — re-check if that matters.
DateTime? hintFireTime({
  required DateTime desiredLocal,
  required NotificationSettings settings,
  Set<DateTime> otherHintDays = const {},
}) {
  final when = settings.quietHoursEnabled
      ? _afterQuietHours(desiredLocal)
      : desiredLocal;
  if (settings.frequencyCapEnabled && otherHintDays.contains(startOfDay(when))) {
    return null;
  }
  return when;
}

DateTime _afterQuietHours(DateTime local) {
  if (!inQuietHours(local)) return local;
  // Before dawn the hint waits for the same morning; after the evening start it
  // waits for the next one. Day overflow is normalized by DateTime itself.
  final day = local.hour >= kQuietHoursStartHour ? local.day + 1 : local.day;
  return DateTime(local.year, local.month, day, kQuietHoursEndHour);
}
