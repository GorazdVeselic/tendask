import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/moon_colors.dart';
import '../../../moon/application/moon_month_provider.dart';
import '../../../moon/presentation/widgets/moon_phase_icon.dart';

/// How many task dots a day cell shows at most.
const _kMaxDots = 3;

/// One day of the month grid: its number, up to three task dots, and the
/// today/selected accents. With [moonDay] set the moon layer paints the
/// element soft tone as background and a principal-phase marker next to the
/// number (FR-19 T4.4, board C) — dots and accents stay unchanged.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.count,
    required this.isToday,
    required this.selected,
    required this.onTap,
    this.moonDay,
  });

  final DateTime day;
  final int count;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;
  final MoonMonthDay? moonDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moonDay = this.moonDay;
    final moon = MoonColors.of(context);

    final number = Text(
      '${day.day}',
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: (isToday || selected) ? FontWeight.w700 : FontWeight.w500,
        // Today's number stays green even when the day is selected.
        color: isToday ? theme.colorScheme.primary : null,
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // Moon layer wins the fill (board C: selection stays on the border);
          // otherwise selected = honey fill (distinct from today's green) and
          // today keeps a light fill so the task dots stay visible.
          color: moonDay != null
              ? moon.softOf(moonDay.element)
              : selected
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
            if (moonDay?.principalPhase case final phase?)
              // Scale down rather than overflow: at the 320 px viewport a
              // two-digit number + phase icon exceed the cell width.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    number,
                    const SizedBox(width: 2),
                    MoonPhaseIcon(
                      phase: phase,
                      illumFraction: principalIllumFraction(phase),
                      size: 10,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              )
            else
              number,
            const SizedBox(height: 3),
            if (count > 0)
              // Scale down rather than overflow: at the 320 px viewport with
              // large font scale the number plus dots exceed the cell height.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
