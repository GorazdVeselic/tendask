import 'package:flutter/material.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../task_detail_labels.dart';

/// Task detail header: type icon, type name, subjects and the status pill.
class TaskHero extends StatelessWidget {
  const TaskHero({
    super.key,
    required this.task,
    required this.taskType,
    required this.subjectLabel,
  });

  final Task task;
  final TaskType? taskType;
  final String? subjectLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = taskType;
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              type?.icon ?? '📋',
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subjectLabel != null && subjectLabel!.isNotEmpty)
                Text(
                  '🪴 $subjectLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 6),
              _StatusPill(task: task),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusPillLabel(task, context.t),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
