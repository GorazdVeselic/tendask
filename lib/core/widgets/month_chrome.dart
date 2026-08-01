import 'package:flutter/material.dart';

/// The month title with its prev/next arrows.
class MonthNav extends StatelessWidget {
  const MonthNav({
    super.key,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: theme.colorScheme.primary,
          onPressed: onPrev,
        ),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: theme.colorScheme.primary,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// The weekday initials above the grid, starting on the locale's first weekday.
class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key, required this.ml});

  final MaterialLocalizations ml;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                ml.narrowWeekdays[(ml.firstDayOfWeekIndex + i) % 7],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
