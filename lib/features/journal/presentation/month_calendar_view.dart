import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import '../../tasks/application/tasks_providers.dart';

/// Cells for the month grid: leading `null`s to align the 1st under the right
/// weekday, then one [DateTime] per day. [firstWeekday] is 0=Sunday..6=Saturday
/// (as in [MaterialLocalizations.firstDayOfWeekIndex]).
List<DateTime?> monthCells(DateTime month, int firstWeekday) {
  final first = DateTime(month.year, month.month);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  // DateTime.weekday: Mon=1..Sun=7 → normalize to 0=Sun..6=Sat.
  final firstCol = (first.weekday % 7 - firstWeekday + 7) % 7;
  return [
    for (var i = 0; i < firstCol; i++) null,
    for (var d = 1; d <= daysInMonth; d++) DateTime(month.year, month.month, d),
  ];
}

class MonthCalendarView extends ConsumerStatefulWidget {
  const MonthCalendarView({super.key});

  @override
  ConsumerState<MonthCalendarView> createState() => _MonthCalendarViewState();
}

class _MonthCalendarViewState extends ConsumerState<MonthCalendarView> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shift(int months) {
    setState(() =>
        _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + months));
  }

  void _addTask(DateTime day) {
    final now = DateTime.now();
    final dt = DateTime(day.year, day.month, day.day, now.hour, now.minute);
    context.pushNamed('task-new',
        queryParameters: {'date': dt.toIso8601String()});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final ml = MaterialLocalizations.of(context);
    final tasks = ref.watch(allTasksProvider).asData?.value ?? const [];

    // Tasks per day-of-month within the visible month.
    final counts = <int, int>{};
    var monthTotal = 0;
    for (final task in tasks) {
      final d = task.date.toLocal();
      if (d.year == _visibleMonth.year && d.month == _visibleMonth.month) {
        counts[d.day] = (counts[d.day] ?? 0) + 1;
        monthTotal++;
      }
    }

    final cells = monthCells(_visibleMonth, ml.firstDayOfWeekIndex);
    final today = startOfDay(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _MonthNav(
          label: ml.formatMonthYear(_visibleMonth),
          onPrev: () => _shift(-1),
          onNext: () => _shift(1),
          theme: theme,
        ),
        const SizedBox(height: 4),
        Text(
          t.journal.month_count(n: monthTotal),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          t.journal.month_hint,
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _WeekdayHeader(ml: ml, theme: theme),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: cells.length,
          itemBuilder: (context, i) {
            final day = cells[i];
            if (day == null) return const SizedBox.shrink();
            return _DayCell(
              day: day,
              count: counts[day.day] ?? 0,
              isToday: startOfDay(day) == today,
              theme: theme,
              onTap: () => _addTask(day),
            );
          },
        ),
      ],
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.theme,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.ml, required this.theme});

  final MaterialLocalizations ml;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                ml.narrowWeekdays[(ml.firstDayOfWeekIndex + i) % 7],
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.isToday,
    required this.theme,
    required this.onTap,
  });

  final DateTime day;
  final int count;
  final bool isToday;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            if (count > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < math.min(count, 3); i++)
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
