import 'dart:math' as math;

import 'package:flutter/material.dart';

/// How many task dots a day cell shows at most.
const _kMaxDots = 3;

/// One day of the month grid: its number, up to three task dots, and the
/// today/selected accents.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.count,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final int count;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // Selected = honey fill (distinct from today's green); today keeps a
          // light fill so the task dots stay visible.
          color: selected
              ? theme.colorScheme.secondary.withValues(alpha: 0.18)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: theme.colorScheme.secondary, width: 2.5)
              : isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: (isToday || selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                // Today's number stays green even when the day is selected.
                color: isToday ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 3),
            if (count > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < math.min(count, _kMaxDots); i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
