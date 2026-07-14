import '../../../../core/config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/task_status.dart';
import '../../../supplies/data/supply_spec.dart';
import '../../data/recurrence.dart';
import '../../data/tasks_repository.dart';
import '../../harvest.dart';
import '../../yield_unit.dart';

/// What the entry wizard actually persists. The draft the user sees is not it:
/// a done task drops its reminders, an unseen supplies step must not book stock,
/// and a type change away from harvest drops the recorded yield.
class EntrySaveSpec {
  const EntrySaveSpec({
    required this.reminders,
    required this.recurrence,
    required this.supplies,
    required this.yieldAmount,
    required this.yieldUnit,
    required this.typeRecordsYield,
  });

  final List<ReminderSpec> reminders;
  final Recurrence? recurrence;
  final List<SupplySpec> supplies;
  final double? yieldAmount;
  final YieldUnit? yieldUnit;

  /// False only for a *known* non-harvest type — the repo then clears the yield.
  final bool typeRecordsYield;
}

/// Resolves the draft into what gets written. [type] is null when the catalog
/// has not loaded — the safe default then differs by mode, so it is explicit.
EntrySaveSpec resolveSave({
  required TaskType? type,
  required bool isEdit,
  required TaskStatus status,
  required List<ReminderSpec> reminders,
  required Recurrence? recurrence,
  required List<SupplySpec> supplies,
  required double? yieldAmount,
  required YieldUnit? yieldUnit,
}) {
  final isWaiting = status == TaskStatus.waiting;

  // Persist supplies only when the final type consumes them: switching to a KNOWN
  // non-consuming type must not silently book stock the user can't see (the step
  // is hidden), and empty specs reconcile an edit that moved away from a consuming
  // type — returning previously booked stock. With the type unresolved, keep the
  // buffer on edit (don't wipe already-booked stock) and drop it on create
  // (nothing is booked yet, so the safe default is to not book unseen consumption).
  final keepSupplies = type == null
      ? isEdit
      : kSuppliesEnabled && type.consumesSupplies;

  // Yield is only meaningful when logging a harvest as already done.
  final harvestDone =
      !isEdit && status == TaskStatus.done && isHarvestType(type);

  return EntrySaveSpec(
    // Reminders and recurrence only make sense for a planned (waiting) task.
    reminders: isWaiting ? reminders : const [],
    recurrence: isWaiting ? recurrence : null,
    supplies: keepSupplies ? supplies : const [],
    yieldAmount: harvestDone ? yieldAmount : null,
    yieldUnit: harvestDone ? yieldUnit : null,
    // Preserve the yield when the type is unknown — only a positively non-harvest
    // type clears it.
    typeRecordsYield: type == null || isHarvestType(type),
  );
}
