import 'package:flutter/material.dart';

/// Compact inline placeholder for the dashboard — a short contextual note ("no
/// tasks today"), not a full-screen list empty (that is [EmptyState]).
class DashboardHint extends StatelessWidget {
  const DashboardHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
