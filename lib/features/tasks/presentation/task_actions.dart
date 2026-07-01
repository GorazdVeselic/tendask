import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../i18n/translations.g.dart';
import '../data/tasks_repository.dart';
import '../yield_unit.dart';
import 'yield_sheet.dart';

/// Completes a task and, when it was recurring, shows a top toast with the next
/// instance's date. The toast lives in the root overlay, so it survives a screen
/// pop (completing from the detail screen).
///
/// For a harvest task ([harvest] true), first offers a skip-able yield sheet
/// (T11) — the recorded amount is frozen onto this instance. Skipping or
/// dismissing still completes the task: yield is always optional.
Future<void> completeTask(
  BuildContext context,
  TasksRepository repo,
  String id, {
  bool harvest = false,
}) async {
  double? yieldAmount;
  YieldUnit? yieldUnit;
  if (harvest) {
    final result = await showYieldSheet(context, allowSkip: true);
    if (result is YieldSaved) {
      yieldAmount = result.draft.amount;
      yieldUnit = result.draft.unit;
    }
  }
  final next = await repo.complete(
    id,
    yieldAmount: yieldAmount,
    yieldUnit: yieldUnit,
  );
  if (next == null || !context.mounted) return;
  showTopToast(
    context,
    context.t.tasks_list.completed_recurring_toast(date: formatDmy(next)),
  );
}

/// Reverts a task to waiting — unless it is a completed recurring instance whose
/// successor already exists (FR-5 D1), in which case it shows a quiet blocked
/// toast instead (the repo guards this path too).
void revertTask(BuildContext context, TasksRepository repo, Task task) {
  // Only a *completed* recurring task is blocked — it already spawned its
  // successor (D1). A waiting one has no successor yet, so revert is harmless.
  if (task.status == TaskStatus.done && task.recurrence != null) {
    showTopToast(context, context.t.tasks_list.revert_blocked_recurring);
    return;
  }
  unawaited(repo.revertToWaiting(task.id));
}
