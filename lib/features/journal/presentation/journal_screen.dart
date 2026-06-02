import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../features/tasks/application/tasks_providers.dart';
import '../../../i18n/translations.g.dart';

enum _Filter { all, tasks, notes }

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    final completed = ref.watch(completedTasksProvider).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final areas = ref.watch(areasMapProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.journal.title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(t.journal.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            filter: _filter,
            onChanged: (f) => setState(() => _filter = f),
            t: t,
          ),
          Expanded(
            child: completed == null || catalog == null || areas == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _JournalList(
                    tasks: completed,
                    catalog: catalog,
                    areas: areas,
                    filter: _filter,
                    t: t,
                    theme: theme,
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.onChanged,
    required this.t,
  });

  final _Filter filter;
  final ValueChanged<_Filter> onChanged;
  final Translations t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _FilterChip(
            label: t.journal.filter_all,
            selected: filter == _Filter.all,
            onTap: () => onChanged(_Filter.all),
            theme: theme,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: t.journal.filter_tasks,
            selected: filter == _Filter.tasks,
            onTap: () => onChanged(_Filter.tasks),
            theme: theme,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: t.journal.filter_notes,
            selected: filter == _Filter.notes,
            onTap: () => onChanged(_Filter.notes),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Journal list — groups completed tasks by date
// ---------------------------------------------------------------------------

class _JournalList extends StatelessWidget {
  const _JournalList({
    required this.tasks,
    required this.catalog,
    required this.areas,
    required this.filter,
    required this.t,
    required this.theme,
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final Map<String, Area> areas;
  final _Filter filter;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final showTasks = filter == _Filter.all || filter == _Filter.tasks;

    final filteredTasks = showTasks ? tasks : <Task>[];

    // Notes are M3.4 — filter_notes always yields empty for now
    if (filteredTasks.isEmpty) {
      final msg = filter == _Filter.notes
          ? t.journal.empty_notes
          : filter == _Filter.tasks
              ? t.journal.empty_tasks
              : t.journal.empty;
      return EmptyState(msg);
    }

    final groups = _groupByDate(filteredTasks);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: groups.length,
      itemBuilder: (context, i) => _DayGroup(
        date: groups[i].date,
        tasks: groups[i].tasks,
        catalog: catalog,
        areas: areas,
        t: t,
        theme: theme,
      ),
    );
  }

  static List<_DateGroup> _groupByDate(List<Task> tasks) {
    final map = <String, _DateGroup>{};
    for (final task in tasks) {
      final local = task.date.toLocal();
      final key =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => _DateGroup(local, [])).tasks.add(task);
    }
    return map.values.toList();
  }
}

class _DateGroup {
  _DateGroup(this.date, this.tasks);
  final DateTime date;
  final List<Task> tasks;
}

// ---------------------------------------------------------------------------
// Day group
// ---------------------------------------------------------------------------

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.date,
    required this.tasks,
    required this.catalog,
    required this.areas,
    required this.t,
    required this.theme,
  });

  final DateTime date;
  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final Map<String, Area> areas;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeader(date: date, t: t, theme: theme),
          const SizedBox(height: 6),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  _TaskEntry(
                    task: tasks[i],
                    taskType: catalog[tasks[i].taskTypeId],
                    area: areas[tasks[i].areaId],
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.t, required this.theme});

  final DateTime date;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final today = startOfDay(DateTime.now());
    final d = startOfDay(date);

    final String label;
    if (d == today) {
      label = t.common.today;
    } else if (d == today.subtract(const Duration(days: 1))) {
      label = t.common.yesterday;
    } else {
      label = formatDmy(date);
    }

    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TaskEntry extends StatelessWidget {
  const _TaskEntry({
    required this.task,
    required this.taskType,
    required this.area,
    required this.theme,
  });

  final Task task;
  final TaskType? taskType;
  final Area? area;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final icon = taskType?.icon ?? '📋';
    final label =
        taskType != null ? catalogLabel(taskType!.labels) : task.taskTypeId;
    final timeStr = formatHm(task.date.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Text(icon, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: area != null
          ? Text('🪴 ${area!.name}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: Text(timeStr,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () => context.pushNamed('task-detail',
          pathParameters: {'id': task.id}),
    );
  }
}
