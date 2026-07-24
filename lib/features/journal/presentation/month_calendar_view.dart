import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/presentation/subject_labels.dart';
import 'month_grid.dart';
import 'widgets/day_cell.dart';
import 'widgets/month_chrome.dart';
import 'widgets/task_entry_tile.dart';

class MonthCalendarView extends ConsumerStatefulWidget {
  const MonthCalendarView({super.key});

  @override
  ConsumerState<MonthCalendarView> createState() => _MonthCalendarViewState();
}

class _MonthCalendarViewState extends ConsumerState<MonthCalendarView> {
  late DateTime _visibleMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    // Open on today so the day list is populated immediately.
    _selectedDay = preselectedDay(_visibleMonth, now);
  }

  void _shift(int months) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + months,
      );
      _selectedDay = preselectedDay(_visibleMonth, DateTime.now());
    });
  }

  void _addTask(DateTime day) {
    final at = combineDateAndTime(day, DateTime.now());
    context.pushNamed(
      'task-new',
      queryParameters: {'date': at.toIso8601String()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final ml = MaterialLocalizations.of(context);

    final tasks = ref.watch(allTasksProvider).asData?.value ?? const [];
    final catalog = ref.watch(taskTypesMapProvider).asData?.value ?? const {};
    final subjectLabels = subjectLabelsByTask(
      ref.watch(allTaskSubjectsProvider).asData?.value ?? const [],
      areas: ref.watch(areasMapProvider).asData?.value ?? const {},
      userPlants: ref.watch(userPlantsMapProvider).asData?.value ?? const {},
      plants: ref.watch(plantsMapProvider).asData?.value ?? const {},
    );

    final selected = _selectedDay;
    final dayTasks = selected == null
        ? const <Task>[]
        : tasksOnDay(tasks, selected);
    final counts = taskCountsInMonth(tasks, _visibleMonth);
    final cells = monthCells(_visibleMonth, ml.firstDayOfWeekIndex);
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        MonthNav(
          label: ml.formatMonthYear(_visibleMonth),
          onPrev: () => _shift(-1),
          onNext: () => _shift(1),
        ),
        const SizedBox(height: 4),
        Text(
          t.journal.month_count(n: counts.total),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.journal.month_hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        WeekdayHeader(ml: ml),
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
            return DayCell(
              day: day,
              count: counts.byDay[day.day] ?? 0,
              isToday: isSameDay(day, now),
              selected: selected != null && isSameDay(day, selected),
              onTap: () => setState(() => _selectedDay = day),
            );
          },
        ),
        if (selected != null) ...[
          const SizedBox(height: 20),
          SectionLabel(
            formatDmy(selected),
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          ),
          if (dayTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                t.journal.day_empty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final task in dayTasks)
              TaskEntryTile(
                task: task,
                taskType: catalog[task.taskTypeId],
                subjectLabel: subjectLabels[task.id],
              ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addTask(selected),
              icon: const Icon(Icons.add, size: 18),
              label: Text(t.journal.day_add),
            ),
          ),
        ],
      ],
    );
  }
}
