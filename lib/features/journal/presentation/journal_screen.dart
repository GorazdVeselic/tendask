import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/presentation/subject_labels.dart';
import '../application/notes_providers.dart';
import 'journal_entry.dart';
import 'journal_timeline.dart';
import 'month_calendar_view.dart';
import 'widgets/journal_day_card.dart';
import 'widgets/journal_filter_bar.dart';

enum _View { timeline, month }

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  JournalFilter _filter = JournalFilter.all;
  _View _view = _View.timeline;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    final completed = ref.watch(completedTasksProvider).asData?.value;
    final notes = ref.watch(notesProvider).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final areas = ref.watch(areasMapProvider).asData?.value;

    final subjectLabels = subjectLabelsByTask(
      ref.watch(allTaskSubjectsProvider).asData?.value ?? const [],
      areas: areas ?? const {},
      userPlants: ref.watch(userPlantsMapProvider).asData?.value ?? const {},
      plants: ref.watch(plantsMapProvider).asData?.value ?? const {},
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.journal.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.journal.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SegmentedButton<_View>(
              segments: [
                ButtonSegment(
                  value: _View.timeline,
                  label: Text(t.journal.timeline),
                ),
                ButtonSegment(
                  value: _View.month,
                  label: Text(t.journal.month_view),
                ),
              ],
              selected: {_view},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _view = s.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
          if (_view == _View.timeline)
            JournalFilterBar(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          Expanded(
            child: _view == _View.month
                ? const MonthCalendarView()
                : completed == null ||
                      notes == null ||
                      catalog == null ||
                      areas == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _Timeline(
                    entries: journalEntries(
                      tasks: completed,
                      notes: notes,
                      filter: _filter,
                    ),
                    filter: _filter,
                    catalog: catalog,
                    areas: areas,
                    subjectLabels: subjectLabels,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.entries,
    required this.filter,
    required this.catalog,
    required this.areas,
    required this.subjectLabels,
  });

  final List<JournalEntry> entries;
  final JournalFilter filter;
  final Map<String, TaskType> catalog;
  final Map<String, Area> areas;
  final Map<String, String> subjectLabels;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (entries.isEmpty) return EmptyState(journalEmptyMessage(filter, t));

    final days = groupEntriesByDay(entries);
    final now = DateTime.now();

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: days.length,
        itemBuilder: (context, i) => JournalDayCard(
          group: days[i],
          now: now,
          catalog: catalog,
          areas: areas,
          subjectLabels: subjectLabels,
        ),
      ),
    );
  }
}
