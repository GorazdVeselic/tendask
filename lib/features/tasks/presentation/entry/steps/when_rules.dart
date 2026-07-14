import '../../../../../core/date_format.dart';
import '../../../data/recurrence.dart';

/// The quick date choice above the explicit date field.
enum WhenPreset { today, tomorrow, custom }

/// The preset [date] currently matches, relative to [now].
WhenPreset whenPreset(DateTime date, DateTime now) {
  final today = startOfDay(now);
  final day = startOfDay(date);

  if (day == today) return WhenPreset.today;
  if (day == today.add(const Duration(days: 1))) return WhenPreset.tomorrow;
  return WhenPreset.custom;
}

/// The date a preset selects, keeping the time of day already set. Null for
/// [WhenPreset.custom] — that one opens the date picker instead of deciding.
DateTime? dateForPreset(WhenPreset preset, DateTime current, DateTime now) {
  final today = startOfDay(now);
  return switch (preset) {
    WhenPreset.today => combineDateAndTime(today, current),
    WhenPreset.tomorrow => combineDateAndTime(
      today.add(const Duration(days: 1)),
      current,
    ),
    WhenPreset.custom => null,
  };
}

/// The recurrence frequency the sub-form is on.
enum RecurrenceMode { off, daily, weekly, custom }

RecurrenceMode recurrenceModeOf(Recurrence? recurrence) {
  if (recurrence == null) return RecurrenceMode.off;
  if (recurrence.everyDays == 1) return RecurrenceMode.daily;
  if (recurrence.everyDays == 7) return RecurrenceMode.weekly;
  return RecurrenceMode.custom;
}

/// What the recurrence sub-form currently means: the rule it would save (null =
/// no recurrence), whether its shown number fields are complete, and which one
/// is wrong. [valid] false must block "Continue" — never save a half-typed rule.
typedef RecurrenceDraft = ({
  Recurrence? rule,
  bool valid,
  bool intervalInvalid,
  bool countInvalid,
  int everyDays,
});

/// Reads the raw field text of the recurrence sub-form. A field that is not
/// shown never blocks: text left behind an off/daily mode, or behind an
/// unchecked cap, is not what the user is asking for.
RecurrenceDraft evaluateRecurrence({
  required RecurrenceMode mode,
  required String intervalText,
  required bool limited,
  required String countText,
}) {
  final interval = int.tryParse(intervalText);
  final repeats = int.tryParse(countText);

  final intervalInvalid =
      mode == RecurrenceMode.custom && (interval == null || interval < 1);
  final countInvalid =
      mode != RecurrenceMode.off &&
      limited &&
      (repeats == null || repeats < 1);

  final everyDays = switch (mode) {
    RecurrenceMode.daily => 1,
    RecurrenceMode.weekly => 7,
    RecurrenceMode.custom => interval ?? 1,
    RecurrenceMode.off => 1,
  };

  if (mode == RecurrenceMode.off || intervalInvalid || countInvalid) {
    return (
      rule: null,
      valid: mode == RecurrenceMode.off,
      intervalInvalid: intervalInvalid,
      countInvalid: countInvalid,
      everyDays: everyDays,
    );
  }

  return (
    rule: Recurrence(everyDays: everyDays, remaining: limited ? repeats : null),
    valid: true,
    intervalInvalid: false,
    countInvalid: false,
    everyDays: everyDays,
  );
}
