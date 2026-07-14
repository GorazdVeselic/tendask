import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';
import 'confirm_delete_dialog.dart';

/// The sticky bottom bar of the task detail: one primary action plus four
/// secondary ones, different for a waiting and a done task.
class TaskActionBar extends StatelessWidget {
  const TaskActionBar({
    super.key,
    required this.isWaiting,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onRevert,
    required this.onMove,
  });

  final bool isWaiting;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onRevert;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isWaiting
                ? FilledButton(
                    onPressed: onComplete,
                    child: Text(t.task_detail.action_complete),
                  )
                : FilledButton.tonal(
                    onPressed: onEdit,
                    child: Text('✏️  ${t.task_detail.action_edit}'),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: isWaiting
                ? [
                    _SecBtn(
                      icon: Icons.schedule_outlined,
                      label: t.task_detail.action_postpone,
                      onTap: onPostpone,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.edit_outlined,
                      label: t.task_detail.action_edit,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.copy_outlined,
                      label: t.task_detail.action_duplicate,
                      onTap: onDuplicate,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.delete_outline,
                      label: t.task_detail.action_delete,
                      isDanger: true,
                      onTap: () => unawaited(_confirmDelete(context)),
                    ),
                  ]
                : [
                    _SecBtn(
                      icon: Icons.copy_outlined,
                      label: t.task_detail.action_duplicate,
                      onTap: onDuplicate,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.calendar_today_outlined,
                      label: t.task_detail.action_move,
                      onTap: onMove,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.undo,
                      label: t.task_detail.action_revert,
                      onTap: onRevert,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.delete_outline,
                      label: t.task_detail.action_delete,
                      isDanger: true,
                      onTap: () => unawaited(_confirmDelete(context)),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (await showConfirmDeleteDialog(context)) onDelete();
  }
}

class _SecBtn extends StatelessWidget {
  const _SecBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDanger
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isDanger
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurface;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
