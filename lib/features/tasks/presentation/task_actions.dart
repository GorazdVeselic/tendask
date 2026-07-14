import 'dart:async';

import 'package:flutter/material.dart';

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

/// Moves a task to another day, keeping the time of day it was set for. A
/// dismissed picker changes nothing.
Future<void> moveTask(
  BuildContext context,
  TasksRepository repo,
  Task task,
) async {
  final current = task.date.toLocal();
  final picked = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
  );
  if (picked == null) return;
  // context is not used after the await — only the repo (lint-safe).
  await repo.reschedule(task.id, combineDateAndTime(picked, current));
}

/// Opens the yield sheet for a completed harvest task and writes the result:
/// a saved amount replaces the frozen one, "remove" clears it, dismissing the
/// sheet changes nothing.
Future<void> editYield(
  BuildContext context,
  TasksRepository repo,
  Task task,
) async {
  final amount = task.yieldAmount;
  final unit = yieldUnitFromName(task.yieldUnit);
  final initial = (amount != null && unit != null)
      ? YieldDraft(amount: amount, unit: unit)
      : null;
  final result = await showYieldSheet(
    context,
    initial: initial,
    allowRemove: initial != null,
  );
  switch (result) {
    case null:
      return; // dismissed → no change
    case YieldSaved(:final draft):
      await repo.setYield(task.id, amount: draft.amount, unit: draft.unit);
    case YieldCleared():
      await repo.setYield(task.id, amount: null, unit: null);
  }
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
