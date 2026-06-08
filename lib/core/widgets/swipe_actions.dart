import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../i18n/translations.g.dart';
import 'confirm_dialog.dart';

/// Brand-aligned colours for reveal-swipe action buttons (no off-brand blue/red).
/// Values live in the theme (app_theme builds the light/dark instances); widgets
/// read them via `Theme.of(context).extension<SwipeColors>()`.
@immutable
class SwipeColors extends ThemeExtension<SwipeColors> {
  const SwipeColors({
    required this.complete,
    required this.onComplete,
    required this.postpone,
    required this.onPostpone,
    required this.neutral,
    required this.onNeutral,
    required this.delete,
    required this.onDelete,
  });

  final Color complete; // ✓ done
  final Color onComplete;
  final Color postpone; // ⏰ +1 day
  final Color onPostpone;
  final Color neutral; // ↩ ✏️ ↔ revert / edit / move
  final Color onNeutral;
  final Color delete; // 🗑 destructive (terracotta)
  final Color onDelete;

  @override
  SwipeColors copyWith({
    Color? complete,
    Color? onComplete,
    Color? postpone,
    Color? onPostpone,
    Color? neutral,
    Color? onNeutral,
    Color? delete,
    Color? onDelete,
  }) => SwipeColors(
    complete: complete ?? this.complete,
    onComplete: onComplete ?? this.onComplete,
    postpone: postpone ?? this.postpone,
    onPostpone: onPostpone ?? this.onPostpone,
    neutral: neutral ?? this.neutral,
    onNeutral: onNeutral ?? this.onNeutral,
    delete: delete ?? this.delete,
    onDelete: onDelete ?? this.onDelete,
  );

  @override
  SwipeColors lerp(ThemeExtension<SwipeColors>? other, double t) {
    if (other is! SwipeColors) return this;
    return SwipeColors(
      complete: Color.lerp(complete, other.complete, t)!,
      onComplete: Color.lerp(onComplete, other.onComplete, t)!,
      postpone: Color.lerp(postpone, other.postpone, t)!,
      onPostpone: Color.lerp(onPostpone, other.onPostpone, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      onNeutral: Color.lerp(onNeutral, other.onNeutral, t)!,
      delete: Color.lerp(delete, other.delete, t)!,
      onDelete: Color.lerp(onDelete, other.onDelete, t)!,
    );
  }
}

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

/// The theme's swipe palette, or a colorScheme-derived fallback when the
/// extension isn't registered (e.g. a bare MaterialApp in a widget test).
SwipeColors _colors(BuildContext context) {
  final ext = Theme.of(context).extension<SwipeColors>();
  if (ext != null) return ext;
  final cs = Theme.of(context).colorScheme;
  return SwipeColors(
    complete: cs.primary,
    onComplete: cs.onPrimary,
    postpone: cs.secondary,
    onPostpone: cs.onSecondary,
    neutral: cs.onSurfaceVariant,
    onNeutral: cs.surface,
    delete: cs.error,
    onDelete: cs.onError,
  );
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
  final c = _colors(context);
  return _action(
    background: c.complete,
    foreground: c.onComplete,
    icon: Icons.check,
    label: context.t.swipe.complete,
    onPressed: (_) => onPressed(),
  );
}

/// ⏰ honey — push a waiting task one day.
SlidableAction postponeSwipe(BuildContext context, VoidCallback onPressed) {
  final c = _colors(context);
  return _action(
    background: c.postpone,
    foreground: c.onPostpone,
    icon: Icons.schedule,
    label: context.t.swipe.postpone,
    onPressed: (_) => onPressed(),
  );
}

/// ↩ neutral — reopen a done task (back to waiting).
SlidableAction revertSwipe(BuildContext context, VoidCallback onPressed) {
  final c = _colors(context);
  return _action(
    background: c.neutral,
    foreground: c.onNeutral,
    icon: Icons.undo,
    label: context.t.swipe.revert,
    onPressed: (_) => onPressed(),
  );
}

/// ✏️ neutral — open the editor.
SlidableAction editSwipe(BuildContext context, VoidCallback onPressed) {
  final c = _colors(context);
  return _action(
    background: c.neutral,
    foreground: c.onNeutral,
    icon: Icons.edit_outlined,
    label: context.t.swipe.edit,
    onPressed: (_) => onPressed(),
  );
}

/// ↔ neutral — move a plant between areas.
SlidableAction moveSwipe(BuildContext context, VoidCallback onPressed) {
  final c = _colors(context);
  return _action(
    background: c.neutral,
    foreground: c.onNeutral,
    icon: Icons.swap_horiz,
    label: context.t.swipe.move,
    onPressed: (_) => onPressed(),
  );
}

/// 🗑 terracotta — confirms before running [onConfirmed]. [title]/[body] explain
/// what is being removed in context.
SlidableAction deleteSwipe(
  BuildContext context, {
  required String title,
  required String body,
  required Future<void> Function() onConfirmed,
}) {
  final c = _colors(context);
  return _action(
    background: c.delete,
    foreground: c.onDelete,
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
