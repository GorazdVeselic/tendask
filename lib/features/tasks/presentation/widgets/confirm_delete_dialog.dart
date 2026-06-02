import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';

/// Shows the task delete-confirmation dialog; resolves to `true` if confirmed.
Future<bool> showConfirmDeleteDialog(BuildContext context) async {
  final t = context.t;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.tasks_list.delete_confirm_title),
      content: Text(t.tasks_list.delete_confirm_body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(t.tasks_list.delete_cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(t.tasks_list.delete_yes),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
