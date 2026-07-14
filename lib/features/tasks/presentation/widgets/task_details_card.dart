import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/recurrence.dart';
import '../recurrence_label.dart';

/// Supplies, reminders, recurrence and note. The date is not repeated here — the
/// status pill in the hero already carries it.
class TaskDetailsCard extends StatelessWidget {
  const TaskDetailsCard({
    super.key,
    required this.task,
    required this.suppliesLabel,
    required this.remindersLabel,
  });

  final Task task;
  final String? suppliesLabel;
  final String? remindersLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final note = task.note;

    final rows = [
      (t.task_detail.label_supplies, suppliesLabel ?? t.task_detail.none),
      (t.task_detail.label_reminder, remindersLabel ?? t.task_detail.none),
      (
        t.task_detail.label_recurrence,
        recurrenceLabel(t, Recurrence.tryParse(task.recurrence)),
      ),
      if (note != null && note.isNotEmpty) (t.task_detail.label_note, note),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _InfoRow(label: rows[i].$1, value: rows[i].$2),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
