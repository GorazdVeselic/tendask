import 'package:flutter/material.dart';

/// Quiet centered indicator for a failed local read — a drift error is a bug, so
/// it is surfaced calmly instead of being hidden behind a shrink (CLAUDE.md).
/// Network failures are a normal offline state and must not use this. Named
/// LoadErrorHint because Flutter's foundation already exports an `ErrorHint`.
class LoadErrorHint extends StatelessWidget {
  const LoadErrorHint(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
