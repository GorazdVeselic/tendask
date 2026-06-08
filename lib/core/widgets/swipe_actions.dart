import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../i18n/translations.g.dart';
import 'confirm_dialog.dart';

/// Wraps [child] in a reveal-swipe row: swiping left reveals [actions]; tapping
/// a button runs it. Build the actions with the helpers below so colours, icons
/// and labels stay identical on every screen (tasks, journal, garden).
class SwipeRow extends StatelessWidget {
  const SwipeRow({
    required this.itemKey,
    required this.actions,
    required this.child,
    super.key,
  });

  final String itemKey;
  final List<SlidableAction> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(itemKey),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: actions.length >= 2 ? 0.5 : 0.28,
        children: actions,
      ),
      child: child,
    );
  }
}

SlidableAction _action({
  required Color background,
  required Color foreground,
  required IconData icon,
  required String label,
  required SlidableActionCallback onPressed,
}) => SlidableAction(
  onPressed: onPressed,
  backgroundColor: background,
  foregroundColor: foreground,
  icon: icon,
  label: label,
);

/// ✓ green — mark a waiting task done.
SlidableAction completeSwipe(BuildContext context, VoidCallback onPressed) {
  final cs = Theme.of(context).colorScheme;
  return _action(
    background: cs.primary,
    foreground: cs.onPrimary,
    icon: Icons.check,
    label: context.t.swipe.complete,
    onPressed: (_) => onPressed(),
  );
}

/// ⏰ honey — push a waiting task one day.
SlidableAction postponeSwipe(BuildContext context, VoidCallback onPressed) {
  final cs = Theme.of(context).colorScheme;
  return _action(
    background: cs.secondary,
    foreground: cs.onSecondary,
    icon: Icons.schedule,
    label: context.t.swipe.postpone,
    onPressed: (_) => onPressed(),
  );
}

/// ↩ blue — reopen a done task (back to waiting).
SlidableAction revertSwipe(BuildContext context, VoidCallback onPressed) {
  final cs = Theme.of(context).colorScheme;
  return _action(
    background: cs.tertiary,
    foreground: cs.onTertiary,
    icon: Icons.undo,
    label: context.t.swipe.revert,
    onPressed: (_) => onPressed(),
  );
}

/// ✏️ blue — open the editor.
SlidableAction editSwipe(BuildContext context, VoidCallback onPressed) {
  final cs = Theme.of(context).colorScheme;
  return _action(
    background: cs.tertiary,
    foreground: cs.onTertiary,
    icon: Icons.edit_outlined,
    label: context.t.swipe.edit,
    onPressed: (_) => onPressed(),
  );
}

/// ↔ blue — move a plant between areas.
SlidableAction moveSwipe(BuildContext context, VoidCallback onPressed) {
  final cs = Theme.of(context).colorScheme;
  return _action(
    background: cs.tertiary,
    foreground: cs.onTertiary,
    icon: Icons.swap_horiz,
    label: context.t.swipe.move,
    onPressed: (_) => onPressed(),
  );
}

/// 🗑 red — confirms before running [onConfirmed]. [title]/[body] explain what
/// is being removed in context.
SlidableAction deleteSwipe(
  BuildContext context, {
  required String title,
  required String body,
  required Future<void> Function() onConfirmed,
}) {
  final cs = Theme.of(context).colorScheme;
  return _action(
    background: cs.error,
    foreground: cs.onError,
    icon: Icons.delete_outline,
    label: context.t.swipe.delete,
    onPressed: (ctx) async {
      final ok = await showConfirmDialog(
        ctx,
        title: title,
        body: body,
        confirmLabel: ctx.t.swipe.delete,
        cancelLabel: ctx.t.tasks_list.delete_cancel,
        destructive: true,
      );
      if (ok) await onConfirmed();
    },
  );
}
