import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/section_label.dart';
import '../../../features/tasks/application/tasks_providers.dart';
import '../../../i18n/translations.g.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final pending = ref.watch(pendingTasksProvider);
    final completed = ref.watch(completedTasksProvider);
    final catalogAsync = ref.watch(taskTypesMapProvider);

    final now = DateTime.now();
    final todayLabel = formatDmy(now);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.home.greeting,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              todayLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: catalogAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => const SizedBox.shrink(),
        data: (catalog) => _HomeBody(
          pending: pending,
          completed: completed,
          catalog: catalog,
          now: now,
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.pending,
    required this.completed,
    required this.catalog,
    required this.now,
  });

  final AsyncValue<List<Task>> pending;
  final AsyncValue<List<Task>> completed;
  final Map<String, TaskType> catalog;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    final todayTasks = switch (pending) {
      AsyncData(:final value) => value.where((task) {
          final d = task.date.toLocal();
          return d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
        }).toList(),
      _ => <Task>[],
    };

    final recentTasks = switch (completed) {
      AsyncData(:final value) => value.take(3).toList(),
      _ => <Task>[],
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        _WeatherPlaceholder(label: t.home.weather_placeholder),
        const SizedBox(height: 16),
        SectionLabel(t.home.today, padding: const EdgeInsets.only(bottom: 8)),
        if (todayTasks.isEmpty)
          _DashboardHint(t.home.no_tasks_today)
        else
          _TaskList(tasks: todayTasks, catalog: catalog),
        const SizedBox(height: 16),
        SectionLabel(t.home.recent, padding: const EdgeInsets.only(bottom: 8)),
        if (recentTasks.isEmpty)
          _DashboardHint(t.home.no_recent)
        else
          _TaskList(tasks: recentTasks, catalog: catalog, showRelativeDate: true, now: now, t: t),
      ],
    );
  }
}

class _WeatherPlaceholder extends StatelessWidget {
  const _WeatherPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text('🌤️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline placeholder for the dashboard (not a full-screen list empty).
class _DashboardHint extends StatelessWidget {
  const _DashboardHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          text,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.catalog,
    this.showRelativeDate = false,
    this.now,
    this.t,
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final bool showRelativeDate;
  final DateTime? now;
  final Translations? t;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            _TaskTile(
              task: tasks[i],
              taskType: catalog[tasks[i].taskTypeId],
              trailingText: showRelativeDate && now != null && t != null
                  ? _relative(tasks[i].date, now!, t!)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  static String _relative(DateTime date, DateTime now, Translations t) {
    final d = date.toLocal();
    final diff = now.difference(d);
    if (diff.inDays < 1) return t.common.today;
    if (diff.inDays < 2) return t.common.yesterday;
    return '${d.day}. ${d.month}.';
  }

}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.taskType,
    this.trailingText,
  });

  final Task task;
  final TaskType? taskType;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label =
        taskType != null ? catalogLabel(taskType!.labels) : task.taskTypeId;
    final icon = taskType?.icon ?? '📋';

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: trailingText != null
          ? Text(
              trailingText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => context.pushNamed('task-detail', pathParameters: {'id': task.id}),
    );
  }
}
