import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/date_format.dart';
import '../../../../i18n/translations.g.dart';
import '../../../tasks/presentation/widgets/recurring_badge.dart';
import '../../../tasks/presentation/yield_format.dart';

/// One task row: icon + type label + subject + time; tapping opens the detail.
/// Shared by the journal timeline and the month-calendar day view.
class TaskEntryTile extends StatelessWidget {
  const TaskEntryTile({
    super.key,
    required this.task,
    this.taskType,
    this.subjectLabel,
  });

  final Task task;
  final TaskType? taskType;
  final String? subjectLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = taskType?.icon ?? '📋';
    final label = taskType != null
        ? catalogLabel(taskType!.labels)
        : task.taskTypeId;
    final timeStr = formatHm(task.date.toLocal());

    // Subtitle combines the subject and any recorded harvest yield (T11).
    final yieldChip = taskYieldChip(task, context.t);
    final subtitle = [
      if (subjectLabel != null && subjectLabel!.isNotEmpty) '🪴 $subjectLabel',
      ?yieldChip,
    ].join('   ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Text(icon, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.recurrence != null) ...[
            const RecurringBadge(),
            const SizedBox(width: 6),
          ],
          Text(
            timeStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () =>
          context.pushNamed('task-detail', pathParameters: {'id': task.id}),
    );
  }
}
