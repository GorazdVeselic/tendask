import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/tasks_providers.dart';
import '../../yield_unit.dart';
import '../task_actions.dart';
import '../yield_format.dart';

/// Harvest yield of a completed task — tapping it opens the yield sheet.
class TaskYieldSection extends ConsumerWidget {
  const TaskYieldSection({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final amount = task.yieldAmount;
    final unit = yieldUnitFromName(task.yieldUnit);
    final hasYield = amount != null;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => unawaited(
          // The repo is read before the sheet awaits — a WidgetRef must not be
          // used after an await (the section can unmount while it is open).
          editYield(context, ref.read(tasksRepositoryProvider), task),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('🧺', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasYield ? formatYield(amount, unit, t) : t.harvest.add,
                  style: hasYield
                      ? theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                ),
              ),
              Icon(
                hasYield ? Icons.edit_outlined : Icons.add,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
