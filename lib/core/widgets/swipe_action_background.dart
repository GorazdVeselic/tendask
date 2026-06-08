import 'package:flutter/material.dart';

/// Colored background revealed behind a [Dismissible] row — an icon + label
/// pinned to one side. Shared by the garden plant list and the task list.
class SwipeActionBackground extends StatelessWidget {
  const SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    super.key,
  });

  final Alignment alignment;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;

  /// Match the foreground row's inset/shape when it sits inside a card.
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
