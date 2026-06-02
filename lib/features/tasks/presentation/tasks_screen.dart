import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../areas/application/areas_providers.dart';
import '../application/tasks_providers.dart';
import '../../../i18n/translations.g.dart';
import 'widgets/confirm_delete_dialog.dart';

enum _Group { overdue, today, tomorrow, thisWeek, later }

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

    final pending = ref.watch(pendingTasksProvider).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final areas = ref.watch(areasMapProvider).asData?.value;
    final repo = ref.read(tasksRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.tasks_list.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              t.tasks_list.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed('quick-log'),
          ),
        ],
      ),
      body: pending == null || catalog == null || areas == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _TasksList(
              tasks: pending,
              catalog: catalog,
              areas: areas,
              t: t,
              theme: theme,
              onComplete: (id) => repo.complete(id),
              onPostpone: (id) => repo.postponeOneDay(id),
              onDuplicate: (id) => repo.duplicate(id),
              onDelete: (id) => repo.softDelete(id),
            ),
    );
  }
}

// ─── List ────────────────────────────────────────────────────────────────────

class _TasksList extends StatelessWidget {
  const _TasksList({
    required this.tasks,
    required this.catalog,
    required this.areas,
    required this.t,
    required this.theme,
    required this.onComplete,
    required this.onPostpone,
    required this.onDuplicate,
    required this.onDelete,
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final Map<String, Area> areas;
  final Translations t;
  final ThemeData theme;
  final void Function(String id) onComplete;
  final void Function(String id) onPostpone;
  final void Function(String id) onDuplicate;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return EmptyState(t.tasks_list.empty);

    final grouped = _groupTasks(tasks);
    final sections =
        _Group.values.where((g) => grouped[g]?.isNotEmpty == true).toList();

    // Flat list: _Group (section header) or Task (row)
    final items = <Object>[];
    final taskGroupMap = <String, _Group>{};
    for (final g in sections) {
      items.add(g);
      for (final task in grouped[g]!) {
        items.add(task);
        taskGroupMap[task.id] = g;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is _Group) {
          return _SectionHeader(
            label: _sectionLabel(item, t),
            theme: theme,
          );
        }
        final task = item as Task;
        final group = taskGroupMap[task.id]!;
        return _TaskRow(
          task: task,
          taskType: catalog[task.taskTypeId],
          area: areas[task.areaId],
          group: group,
          t: t,
          theme: theme,
          onComplete: () => onComplete(task.id),
          onPostpone: () => onPostpone(task.id),
          onEdit: () => context.pushNamed(
            'task-edit',
            pathParameters: {'id': task.id},
          ),
          onDuplicate: () => onDuplicate(task.id),
          onDelete: () => onDelete(task.id),
        );
      },
    );
  }

  static Map<_Group, List<Task>> _groupTasks(List<Task> tasks) {
    final today = startOfDay(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    final result = <_Group, List<Task>>{
      for (final g in _Group.values) g: [],
    };

    for (final task in tasks) {
      final day = startOfDay(task.date.toLocal());

      final group = day.isBefore(today)
          ? _Group.overdue
          : day == today
              ? _Group.today
              : day == tomorrow
                  ? _Group.tomorrow
                  : day.isBefore(nextWeek)
                      ? _Group.thisWeek
                      : _Group.later;
      result[group]!.add(task);
    }

    return result;
  }

  static String _sectionLabel(_Group g, Translations t) => switch (g) {
        _Group.overdue => t.tasks_list.section_overdue,
        _Group.today => t.tasks_list.section_today,
        _Group.tomorrow => t.tasks_list.section_tomorrow,
        _Group.thisWeek => t.tasks_list.section_this_week,
        _Group.later => t.tasks_list.section_later,
      };
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Task row ────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.taskType,
    required this.area,
    required this.group,
    required this.t,
    required this.theme,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Task task;
  final TaskType? taskType;
  final Area? area;
  final _Group group;
  final Translations t;
  final ThemeData theme;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = taskType?.icon ?? '📋';
    final label =
        taskType != null ? catalogLabel(taskType!.labels) : task.taskTypeId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.pushNamed(
          'task-detail',
          pathParameters: {'id': task.id},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (area != null)
                      Text(
                        '🪴 ${area!.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(task: task, group: group, t: t, theme: theme),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                onPressed: () => _openActionSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openActionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _ActionSheet(
        t: t,
        theme: theme,
        onComplete: () { Navigator.of(ctx).pop(); onComplete(); },
        onPostpone: () { Navigator.of(ctx).pop(); onPostpone(); },
        onEdit: () { Navigator.of(ctx).pop(); onEdit(); },
        onDuplicate: () { Navigator.of(ctx).pop(); onDuplicate(); },
        onDelete: onDelete,
      ),
    );
  }
}

// ─── Status badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.task,
    required this.group,
    required this.t,
    required this.theme,
  });

  final Task task;
  final _Group group;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (group) {
      _Group.overdue => (_overdueText(), theme.colorScheme.error),
      _Group.today =>
        (t.tasks_list.status_today, theme.colorScheme.primary),
      _Group.tomorrow =>
        (t.tasks_list.status_tomorrow, theme.colorScheme.secondary),
      _Group.thisWeek || _Group.later => (_shortDate(), theme.colorScheme.onSurfaceVariant),
    };

    return Text(
      text,
      textAlign: TextAlign.end,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _overdueText() {
    final days = startOfDay(DateTime.now())
        .difference(startOfDay(task.date.toLocal()))
        .inDays;
    return t.tasks_list.overdue_days(n: days);
  }

  String _shortDate() {
    final local = task.date.toLocal();
    return '${local.day}. ${local.month}.';
  }
}

// ─── Action sheet ─────────────────────────────────────────────────────────────

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    required this.t,
    required this.theme,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Translations t;
  final ThemeData theme;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          ListTile(
            leading: Icon(Icons.check_circle_outline,
                color: theme.colorScheme.primary),
            title: Text(t.tasks_list.action_complete),
            onTap: onComplete,
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: Text(t.tasks_list.action_postpone),
            onTap: onPostpone,
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(t.tasks_list.action_edit),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: Text(t.tasks_list.action_duplicate),
            onTap: onDuplicate,
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              t.tasks_list.action_delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              final sheetNav = Navigator.of(context);
              if (await showConfirmDeleteDialog(context)) {
                sheetNav.pop();
                onDelete();
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

