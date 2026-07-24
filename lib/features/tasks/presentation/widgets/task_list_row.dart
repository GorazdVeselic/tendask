import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/database/app_database.dart';
import '../task_day_groups.dart';
import 'recurring_badge.dart';
import 'task_list_action_sheet.dart';
import 'task_swipe.dart';

/// A single row of the task list. Swiping reveals the status-based actions
/// (waiting → complete / +1 day); the "⋯" sheet keeps the full menu including
/// delete.
class TaskListRow extends StatelessWidget {
  const TaskListRow({
    super.key,
    required this.task,
    required this.taskType,
    required this.subjectLabel,
    required this.hasReminder,
    required this.group,
    required this.statusText,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Task task;
  final TaskType? taskType;
  final String? subjectLabel;
  final bool hasReminder;
  final TaskDayGroup group;
  final String statusText;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = taskType;
    final icon = type?.icon ?? '📋';
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;

    return TaskSwipe(
      task: task,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              context.pushNamed('task-detail', pathParameters: {'id': task.id}),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text(icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subjectLabel != null && subjectLabel!.isNotEmpty)
                        Text(
                          '🪴 $subjectLabel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (task.recurrence != null) ...[
                  const RecurringBadge(),
                  const SizedBox(width: 6),
                ],
                if (hasReminder) ...[
                  Icon(
                    Icons.notifications_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                _StatusBadge(text: statusText, group: group),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => showTaskListActionSheet(
                    context,
                    onComplete: onComplete,
                    onPostpone: onPostpone,
                    onEdit: onEdit,
                    onDuplicate: onDuplicate,
                    onDelete: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.group});

  final String text;
  final TaskDayGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (group) {
      TaskDayGroup.overdue => theme.colorScheme.error,
      TaskDayGroup.today => theme.colorScheme.primary,
      TaskDayGroup.tomorrow => theme.colorScheme.secondary,
      TaskDayGroup.thisWeek ||
      TaskDayGroup.later => theme.colorScheme.onSurfaceVariant,
    };

    return Text(
      text,
      textAlign: TextAlign.end,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
