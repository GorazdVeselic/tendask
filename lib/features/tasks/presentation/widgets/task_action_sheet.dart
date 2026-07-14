import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/haptics.dart';
import '../../../../core/task_status.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/tasks_providers.dart';
import '../task_actions.dart';
import 'confirm_delete_dialog.dart';

/// The "⋯" menu of the task detail. Actions that finish the task (complete,
/// duplicate, delete) pop the detail screen, so [context] must be the screen's —
/// the sheet's own navigator only closes the sheet.
void showTaskActionSheet(
  BuildContext context, {
  required Task task,
  required bool isHarvest,
}) {
  final router = GoRouter.of(context);
  final isWaiting = task.status == TaskStatus.waiting;

  unawaited(
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final t = ctx.t;
        final theme = Theme.of(ctx);
        return Consumer(
          builder: (ctx, ref, _) {
            final repo = ref.read(tasksRepositoryProvider);
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SheetHandle(),
                  if (isWaiting) ...[
                    ListTile(
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(t.task_detail.action_complete),
                      onTap: () {
                        AppHaptics.taskCompleted();
                        Navigator.of(ctx).pop();
                        unawaited(
                          completeTask(
                            context,
                            repo,
                            task.id,
                            harvest: isHarvest,
                          ).then((_) => router.pop()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: Text(t.task_detail.action_postpone),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        unawaited(repo.postponeOneDay(task.id));
                      },
                    ),
                  ] else
                    ListTile(
                      leading: Icon(
                        Icons.undo,
                        color: theme.colorScheme.secondary,
                      ),
                      title: Text(t.task_detail.action_revert),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        revertTask(context, repo, task);
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(t.task_detail.action_edit),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      router.pushNamed(
                        'task-edit',
                        pathParameters: {'id': task.id},
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_outlined),
                    title: Text(t.task_detail.action_duplicate),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      unawaited(
                        repo.duplicate(task.id).then((_) => router.pop()),
                      );
                    },
                  ),
                  if (task.recurrence != null)
                    ListTile(
                      leading: const Icon(Icons.sync_disabled),
                      title: Text(t.task_detail.action_stop_recurrence),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        unawaited(repo.stopRecurrence(task.id));
                      },
                    ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      t.task_detail.action_delete,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    onTap: () async {
                      final sheetNav = Navigator.of(ctx);
                      if (await showConfirmDeleteDialog(ctx)) {
                        sheetNav.pop();
                        unawaited(
                          repo.softDelete(task.id).then((_) => router.pop()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
