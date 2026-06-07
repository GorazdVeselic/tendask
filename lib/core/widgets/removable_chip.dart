import 'package:flutter/material.dart';

/// A compact chip with a trailing ✕ — tapping anywhere removes it. Used in the
/// "selected so far" footers (plant-add, task subjects).
class RemovableChip extends StatelessWidget {
  const RemovableChip({required this.label, required this.onRemove, super.key});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onRemove,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.close, size: 16, color: cs.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
