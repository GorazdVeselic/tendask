import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/task_status.dart';
import '../../../../core/widgets/swipe_actions.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/tasks_providers.dart';

/// Wraps a task row in the shared reveal-swipe with status-appropriate actions:
/// waiting → complete / +1 day, done → reopen / delete. Used by the tasks list,
/// the home dashboard and the journal so the gesture is identical everywhere.
class TaskSwipe extends ConsumerWidget {
  const TaskSwipe({required this.task, required this.child, super.key});

  final Task task;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final repo = ref.read(tasksRepositoryProvider);
    final actions = task.status == TaskStatus.waiting
        ? [
            completeSwipe(context, () => unawaited(repo.complete(task.id))),
            postponeSwipe(
              context,
              () => unawaited(repo.postponeOneDay(task.id)),
            ),
          ]
        : [
            revertSwipe(
              context,
              () => unawaited(repo.revertToWaiting(task.id)),
            ),
            deleteSwipe(
              context,
              title: t.tasks_list.delete_confirm_title,
              body: t.tasks_list.delete_confirm_body,
              onConfirmed: () => repo.softDelete(task.id),
            ),
          ];
    return SwipeRow(itemKey: task.id, actions: actions, child: child);
  }
}
