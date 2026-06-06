import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/section_label.dart';
import '../../../features/tasks/application/tasks_providers.dart';
import '../../../features/weather/application/weather_service.dart';
import '../../../features/weather/presentation/weather_card.dart';
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

class _HomeBody extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final reminderTaskIds =
        ref.watch(taskIdsWithRemindersProvider).asData?.value ?? const {};

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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentWeatherProvider);
        await ref.read(currentWeatherProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          const _WeatherSection(),
        const SizedBox(height: 16),
        SectionLabel(t.home.today, padding: const EdgeInsets.only(bottom: 8)),
        if (todayTasks.isEmpty)
          _DashboardHint(t.home.no_tasks_today)
        else
          _TaskList(
              tasks: todayTasks,
              catalog: catalog,
              now: now,
              reminderTaskIds: reminderTaskIds),
        const SizedBox(height: 16),
        SectionLabel(t.home.recent, padding: const EdgeInsets.only(bottom: 8)),
        if (recentTasks.isEmpty)
          _DashboardHint(t.home.no_recent)
        else
          _TaskList(tasks: recentTasks, catalog: catalog, now: now),
        ],
      ),
    );
  }
}

/// Live weather context for the dashboard. Offline → a quiet "unavailable" card.
class _WeatherSection extends ConsumerWidget {
  const _WeatherSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(currentWeatherProvider);
    if (weather.isLoading) return const _WeatherLoadingCard();
    final snapshot = weather.asData?.value;
    if (snapshot == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref.invalidate(currentWeatherProvider),
        child: const CurrentWeatherCard(snapshot: null),
      );
    }
    return CurrentWeatherCard(snapshot: snapshot);
  }
}

class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
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
    required this.now,
    this.reminderTaskIds = const {},
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final DateTime now;
  final Set<String> reminderTaskIds;

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
              now: now,
              hasReminder: reminderTaskIds.contains(tasks[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.taskType,
    required this.now,
    this.hasReminder = false,
  });

  final Task task;
  final TaskType? taskType;
  final DateTime now;
  final bool hasReminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final label =
        taskType != null ? catalogLabel(taskType!.labels) : task.taskTypeId;
    final icon = taskType?.icon ?? '📋';
    final isDone = task.status == TaskStatus.done;
    // Done tasks show their (calendar-correct) date; waiting tasks show the time.
    final trailingText = isDone
        ? _relative(task.date, now, t)
        : formatHm(task.date.toLocal());

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasReminder && !isDone) ...[
            Icon(Icons.notifications_outlined,
                size: 15, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
          ],
          Icon(
            isDone ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: isDone
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            trailingText,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () =>
          context.pushNamed('task-detail', pathParameters: {'id': task.id}),
    );
  }

  /// Calendar-day relative label (not 24h windows): yesterday 22:00 reads as
  /// "yesterday", not "today".
  static String _relative(DateTime date, DateTime now, Translations t) {
    final days = startOfDay(now).difference(startOfDay(date.toLocal())).inDays;
    if (days <= 0) return t.common.today;
    if (days == 1) return t.common.yesterday;
    return formatDmy(date.toLocal());
  }
}
