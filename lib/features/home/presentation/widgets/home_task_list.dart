import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/date_format.dart';
import '../../../../core/task_status.dart';
import '../../../../i18n/translations.g.dart';
import '../../../tasks/presentation/task_day_groups.dart';
import '../../../tasks/presentation/widgets/recurring_badge.dart';
import '../../../tasks/presentation/widgets/task_swipe.dart';
import '../../../tasks/presentation/yield_format.dart';
import '../home_buckets.dart';

/// A card of dashboard task rows (today, recent, or a banner's expanded list).
class HomeTaskList extends StatelessWidget {
  const HomeTaskList({
    super.key,
    required this.tasks,
    required this.catalog,
    required this.now,
    this.reminderTaskIds = const {},
    this.subjectLabels = const {},
    this.isOverdue = false,
    this.isUpcoming = false,
    this.topAttached = false,
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final DateTime now;
  final Set<String> reminderTaskIds;
  final Map<String, String> subjectLabels;
  final bool isOverdue;
  final bool isUpcoming;

  /// When true, the card sits flush under a banner header: square top corners,
  /// no margin/shadow, so header + list read as one continuous block.
  final bool topAttached;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: topAttached ? EdgeInsets.zero : null,
      elevation: topAttached ? 0 : null,
      shape: topAttached
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            TaskSwipe(
              task: tasks[i],
              child: _TaskTile(
                task: tasks[i],
                taskType: catalog[tasks[i].taskTypeId],
                now: now,
                hasReminder: reminderTaskIds.contains(tasks[i].id),
                subjectLabel: subjectLabels[tasks[i].id],
                isOverdue: isOverdue,
                isUpcoming: isUpcoming,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.taskType,
    required this.now,
    this.hasReminder = false,
    this.subjectLabel,
    this.isOverdue = false,
    this.isUpcoming = false,
  });

  final Task task;
  final TaskType? taskType;
  final DateTime now;
  final bool hasReminder;
  final String? subjectLabel;
  final bool isOverdue;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final type = taskType;
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;
    final isDone = task.status == TaskStatus.done;
    // Done tasks show their (calendar-correct) date; upcoming tasks span several
    // days so they show the day; today's waiting tasks show the time.
    final trailingText = isDone
        ? relativeDayLabel(task.date, now, t)
        : isUpcoming
        ? futureDayLabel(task.date, now, t)
        : formatHm(task.date.toLocal());

    final subject = subjectLabel;
    // Subject + any recorded harvest yield (T11) on one muted subtitle line.
    final subtitleText = [
      if (subject != null && subject.isNotEmpty) '🪴 $subject',
      ?taskYieldChip(task, t),
    ].join('   ');

    return ListTile(
      leading: Text(type?.icon ?? '📋', style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: subtitleText.isEmpty
          ? null
          : Text(
              subtitleText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: isOverdue
          ? Text(
              t.tasks_list.overdue_days(n: overdueDays(task.date, now)),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.recurrence != null) ...[
                  const RecurringBadge(),
                  const SizedBox(width: 6),
                ],
                if (hasReminder && !isDone) ...[
                  Icon(
                    Icons.notifications_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  isDone ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: isDone
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  trailingText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () =>
          context.pushNamed('task-detail', pathParameters: {'id': task.id}),
    );
  }
}
