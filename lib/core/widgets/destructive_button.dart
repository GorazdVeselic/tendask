import 'package:flutter/material.dart';

import 'swipe_actions.dart';

/// Inline destructive action for edit forms — terracotta text button at the
/// bottom of the form content. The single delete-in-form style across the app.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final danger = destructiveColors(context).color;
    return Center(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.delete_outline, color: danger),
        label: Text(label, style: TextStyle(color: danger)),
      ),
    );
  }
}
