import '../../../i18n/translations.g.dart';
import '../data/recurrence.dart';

/// Human label for a recurrence rule: none / daily / weekly / every N days,
/// with a remaining-count suffix when the series is capped. Shared by the task
/// detail and the entry review step.
String recurrenceLabel(Translations t, Recurrence? r) {
  if (r == null) return t.task_detail.recurrence_none;
  final base = switch (r.everyDays) {
    1 => t.task_detail.recurrence_daily,
    7 => t.task_detail.recurrence_weekly,
    _ => t.task_detail.recurrence_every_days(n: r.everyDays),
  };
  final remaining = r.remaining;
  if (remaining == null) return base;
  return '$base${t.task_detail.recurrence_remaining(n: remaining)}';
}
