import 'package:flutter/material.dart';

/// Rounded label pill used wherever a row carries a qualitative verdict:
/// community intensity, timing band, suggestion status. Filled pills read as
/// the positive end of their scale, the outlined one as the quiet tail — so a
/// glance down any of those lists reads as one vocabulary.
///
/// [background] null = outlined. The three call sites all drew the same
/// container from their own copy of these fifteen lines.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.foreground,
    this.background,
    super.key,
  });

  final String label;
  final Color foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        border: background == null
            ? Border.all(color: theme.colorScheme.outline)
            : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
