import 'package:flutter/material.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../i18n/translations.g.dart';

/// Shows the task delete-confirmation dialog; resolves to `true` if confirmed.
Future<bool> showConfirmDeleteDialog(BuildContext context) {
  final t = context.t;
  return showConfirmDialog(
    context,
    title: t.tasks_list.delete_confirm_title,
    body: t.tasks_list.delete_confirm_body,
    confirmLabel: t.tasks_list.delete_yes,
    cancelLabel: t.tasks_list.delete_cancel,
  );
}
