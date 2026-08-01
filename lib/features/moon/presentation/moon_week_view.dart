import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/month_chrome.dart';
import '../../../i18n/translations.g.dart';
import '../application/moon_month_provider.dart';
import '../application/moon_settings_controller.dart';
import 'moon_day_sheet.dart';
import 'moon_text.dart';
import 'widgets/element_badge.dart';
import 'widgets/moon_phase_icon.dart';

/// i18n weekday_short key for a date (DateTime.weekday is Mon=1..Sun=7).
const _weekdayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// The week's [i]-th day out of the memoized month grid, computed directly
/// when the map does not reach it (it carries six leading days, which covers
/// every week today — the fallback keeps a future off-by-one visible as a
/// slower row, not as a missing one).
MoonMonthDay _dayOfWeek(
  Map<DateTime, MoonMonthDay> month,
  DateTime weekStart,
  int i,
  CalendarSystem system,
) {
  final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
  return month[date] ?? moonMonthDayFor(date, system);
}

/// Week tab of the moon calendar (FR-19 T3.4): one agenda row per day with
/// the element day title and an activity description, ‹ › week navigation.
class MoonWeekView extends ConsumerWidget {
  const MoonWeekView({
    super.key,
    required this.weekStart,
    required this.starred,
    required this.onPrev,
    required this.onNext,
  });

  /// Local midnight of the week's first day (locale first weekday).
  final DateTime weekStart;

  /// Elements to mark with ★ (empty when the highlight is off).
  final Set<BiodynamicElement> starred;

  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
    );
    // The month grid of the week's last day covers the whole week (it carries
    // six leading days) — reuses the memoized month instead of a new provider.
    final days = ref.watch(
      moonMonthProvider(DateTime(weekEnd.year, weekEnd.month)),
    );
    final system = ref.watch(moonSystemProvider);
    // Never let a day the month map does not reach drop a row silently: the
    // agenda always shows seven days, computing the odd one out on the spot.
    final weekDays = [
      for (var i = 0; i < 7; i++)
        _dayOfWeek(days, weekStart, i, system),
    ];
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        MonthNav(
          label: '${formatDm(weekStart)} – ${formatDm(weekEnd)}',
          onPrev: onPrev,
          onNext: onNext,
        ),
        const SizedBox(height: 8),
        for (final (i, day) in weekDays.indexed)
          _WeekRow(
            day: day,
            isToday: isSameDay(day.date, now),
            starred: starred.contains(day.element),
            isLast: i == 6,
          ),
      ],
    );
  }
}

/// One agenda row: date column, element glyph column, then the element day
/// title (+ phase event, ★, today marker) and the activity description.
class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.day,
    required this.isToday,
    required this.starred,
    required this.isLast,
  });

  final MoonMonthDay day;
  final bool isToday;
  final bool starred;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final phase = day.principalPhase;

    // Map completeness against BiodynamicElement / MoonPhase / weekday keys is
    // enforced by i18n tests.
    final title = sentenceCase(t.moon.day_for[day.element.name]!);
    final description = phase == MoonPhase.newMoon
        ? t.moon.activity_new_moon
        : t.moon.activity[day.element.name]!;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => showMoonDaySheet(context, day.date),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: isToday
            ? BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(10),
              )
            : isLast
            ? null
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Text(
                    '${day.date.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    t
                        .moon
                        .calendar
                        .weekday_short[_weekdayKeys[day.date.weekday - 1]]!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    elementEmoji(day.element),
                    style: const TextStyle(fontSize: 20, height: 1.2),
                  ),
                  // Scale down instead of clipping: large font scale pushes
                  // the longer labels past the fixed glyph column.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t.moon.element_short[day.element.name]!.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: title),
                        if (phase != null) ...[
                          const TextSpan(text: ' · '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: MoonPhaseIcon(
                              phase: phase,
                              illumFraction: principalIllumFraction(phase),
                              size: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(text: ' ${t.moon.phase[phase.name]!}'),
                        ],
                        if (isToday)
                          TextSpan(text: ' · ${t.moon.calendar.today_marker}'),
                        if (starred)
                          TextSpan(
                            text: ' ★',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
