import 'package:flutter/material.dart';

/// An [EmptyState] that still accepts a pull-to-refresh gesture. A bare Center
/// does not scroll, so the state a user is most likely to pull on would be the
/// one that ignores the pull.
class PullableEmpty extends StatelessWidget {
  const PullableEmpty(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: EmptyState(message),
      ),
    ),
  );
}

/// Centered placeholder text for empty lists.
class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key});

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
