import 'package:flutter/material.dart';

import '../haptics.dart';
import 'swipe_actions.dart';

/// Generic confirmation dialog; resolves to `true` if confirmed.
/// [destructive] tints the confirm button with the destructive (terracotta) color
/// and fires a strong haptic when confirmed (single point for every delete/clear).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: destructiveColors(ctx).color,
                  foregroundColor: destructiveColors(ctx).onColor,
                )
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  final ok = confirmed ?? false;
  if (ok && destructive) AppHaptics.destructiveConfirmed();
  return ok;
}
