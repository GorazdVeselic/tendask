import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../i18n/translations.g.dart';
import '../../supplies/presentation/supply_format.dart';
import '../task_specs.dart';
import 'entry/steps/reminder_step.dart';

/// Consumed supplies as one line, e.g. "Urea 1kg, NPK 0.5kg". Null when the task
/// consumed nothing. A supply missing from the catalog falls back to its id
/// rather than dropping out of the line.
String? taskSuppliesLabel(
  List<TaskSupply> taskSupplies,
  Map<String, Supply> supplyById,
) {
  if (taskSupplies.isEmpty) return null;
  return taskSupplies
      .map((ts) {
        final supply = supplyById[ts.supplyId];
        final amount = formatSupplyQuantity(ts.amount);
        return '${supply?.name ?? ts.supplyId} $amount${supply?.unit ?? ''}';
      })
      .join(', ');
}

/// Active reminders as one line, e.g. "1 dan prej ob 18:00, 1 ura prej". Null
/// when the task has none.
String? taskRemindersLabel(List<TaskReminder> reminders, Translations t) {
  if (reminders.isEmpty) return null;
  return reminders
      .map(
        (r) => reminderLabel(
          ReminderSpec(offsetMinutes: r.offset, time: r.reminderTime),
          t,
        ),
      )
      .join(', ');
}

/// The hero pill: status plus the task's local date and time.
String statusPillLabel(Task task, Translations t) {
  final local = task.date.toLocal();
  final when = '${formatDmy(local)} · ${formatHm(local)}';
  return task.status == TaskStatus.waiting
      ? '📅  ${t.task_detail.badge_waiting} · $when'
      : '✓  ${t.task_detail.badge_done} · $when';
}
