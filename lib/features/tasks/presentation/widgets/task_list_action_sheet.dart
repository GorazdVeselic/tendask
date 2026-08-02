import 'package:flutter/material.dart';

import '../../../../core/app_icons.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../i18n/translations.g.dart';
import 'confirm_delete_dialog.dart';

/// The "⋯" menu of a task-list row. Every action closes the sheet first; delete
/// closes it only after the confirmation is accepted.
void showTaskListActionSheet(
  BuildContext context, {
  required VoidCallback onComplete,
  required VoidCallback onPostpone,
  required VoidCallback onEdit,
  required VoidCallback onDuplicate,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final t = ctx.t;
      final theme = Theme.of(ctx);

      void popThen(VoidCallback action) {
        Navigator.of(ctx).pop();
        action();
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            ListTile(
              leading: Icon(
                kIconCheckCircleOutline,
                color: theme.colorScheme.primary,
              ),
              title: Text(t.tasks_list.action_complete),
              onTap: () => popThen(onComplete),
            ),
            ListTile(
              leading: const Icon(kIconScheduleOutlined),
              title: Text(t.tasks_list.action_postpone),
              onTap: () => popThen(onPostpone),
            ),
            ListTile(
              leading: const Icon(kIconEditOutlined),
              title: Text(t.tasks_list.action_edit),
              onTap: () => popThen(onEdit),
            ),
            ListTile(
              leading: const Icon(kIconCopyOutlined),
              title: Text(t.tasks_list.action_duplicate),
              onTap: () => popThen(onDuplicate),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            ListTile(
              leading: Icon(
                kIconDeleteOutline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                t.tasks_list.action_delete,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                final sheetNav = Navigator.of(ctx);
                if (await showConfirmDeleteDialog(ctx)) {
                  sheetNav.pop();
                  onDelete();
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
