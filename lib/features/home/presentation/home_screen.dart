import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/section_label.dart';
import '../../../features/areas/application/areas_providers.dart';
import '../../../features/plants/application/plants_providers.dart';
import '../../../features/tasks/application/tasks_providers.dart';
import '../../../features/tasks/presentation/subject_labels.dart';
import '../../../features/tasks/presentation/widgets/task_swipe.dart';
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
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              todayLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
        error: (_, _) => Center(child: Text(t.common.load_error)),
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
    final subjectLabels = subjectLabelsByTask(
      ref.watch(allTaskSubjectsProvider).asData?.value ?? const [],
      areas: ref.watch(areasMapProvider).asData?.value ?? const {},
      userPlants: ref.watch(userPlantsMapProvider).asData?.value ?? const {},
      plants: ref.watch(plantsMapProvider).asData?.value ?? const {},
    );

    final todayTasks = switch (pending) {
      AsyncData(:final value) => value.where((task) {
        final d = task.date.toLocal();
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList(),
      _ => <Task>[],
    };

    // Pending tasks whose day is before today — surfaced via a collapsible banner.
    final overdueTasks = switch (pending) {
      AsyncData(:final value) =>
        value
            .where(
              (t) => startOfDay(t.date.toLocal()).isBefore(startOfDay(now)),
            )
            .toList(),
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
      child: SlidableAutoCloseBehavior(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            const _WeatherSection(),
            const SizedBox(height: 16),
            if (overdueTasks.isNotEmpty) ...[
              _OverdueBanner(
                tasks: overdueTasks,
                catalog: catalog,
                now: now,
                subjectLabels: subjectLabels,
              ),
              const SizedBox(height: 16),
            ],
            SectionLabel(
              t.home.today,
              padding: const EdgeInsets.only(bottom: 8),
            ),
            if (todayTasks.isEmpty)
              _DashboardHint(t.home.no_tasks_today)
            else
              _TaskList(
                tasks: todayTasks,
                catalog: catalog,
                now: now,
                reminderTaskIds: reminderTaskIds,
                subjectLabels: subjectLabels,
              ),
            const SizedBox(height: 16),
            SectionLabel(
              t.home.recent,
              padding: const EdgeInsets.only(bottom: 8),
            ),
            if (recentTasks.isEmpty)
              _DashboardHint(t.home.no_recent)
            else
              _TaskList(
                tasks: recentTasks,
                catalog: catalog,
                now: now,
                subjectLabels: subjectLabels,
              ),
          ],
        ),
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
    // Keep the last snapshot visible while a refresh is in flight — the spinner
    // is only for the very first load, when there is nothing to show yet.
    final snapshot = weather.value;
    if (snapshot != null) return CurrentWeatherCard(snapshot: snapshot);
    if (weather.isLoading) return const _WeatherLoadingCard();
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => ref.invalidate(currentWeatherProvider),
      child: const CurrentWeatherCard(snapshot: null),
    );
  }
}

class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              context.t.weather.loading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
    this.subjectLabels = const {},
    this.isOverdue = false,
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final DateTime now;
  final Set<String> reminderTaskIds;
  final Map<String, String> subjectLabels;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            TaskSwipe(
              task: tasks[i],
              child: _TaskTile(
                task: tasks[i],
                taskType: catalog[tasks[i].taskTypeId],
                now: now,
                hasReminder: reminderTaskIds.contains(tasks[i].id),
                subjectLabel: subjectLabels[tasks[i].id],
                isOverdue: isOverdue,
              ),
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
    this.subjectLabel,
    this.isOverdue = false,
  });

  final Task task;
  final TaskType? taskType;
  final DateTime now;
  final bool hasReminder;
  final String? subjectLabel;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final label = taskType != null
        ? catalogLabel(taskType!.labels)
        : task.taskTypeId;
    final icon = taskType?.icon ?? '📋';
    final isDone = task.status == TaskStatus.done;
    // Done tasks show their (calendar-correct) date; waiting tasks show the time.
    final trailingText = isDone
        ? _relative(task.date, now, t)
        : formatHm(task.date.toLocal());
    final overdueDays = startOfDay(
      now,
    ).difference(startOfDay(task.date.toLocal())).inDays;

    final subject = subjectLabel;
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: subject != null && subject.isNotEmpty
          ? Text(
              '🪴 $subject',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: isOverdue
          ? Text(
              t.tasks_list.overdue_days(n: overdueDays),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasReminder && !isDone) ...[
                  Icon(
                    Icons.notifications_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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

/// Collapsible overdue summary: a quiet red bar showing the count; tapping it
/// expands the list of overdue tasks in place (no jump to another screen).
class _OverdueBanner extends StatefulWidget {
  const _OverdueBanner({
    required this.tasks,
    required this.catalog,
    required this.now,
    required this.subjectLabels,
  });

  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final DateTime now;
  final Map<String, String> subjectLabels;

  @override
  State<_OverdueBanner> createState() => _OverdueBannerState();
}

class _OverdueBannerState extends State<_OverdueBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.terracottaSoft,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: Radius.circular(_expanded ? 0 : 12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.onTerracottaSoft,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.home.overdue_banner(n: widget.tasks.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onTerracottaSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.onTerracottaSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          _TaskList(
            tasks: widget.tasks,
            catalog: widget.catalog,
            now: widget.now,
            subjectLabels: widget.subjectLabels,
            isOverdue: true,
          ),
      ],
    );
  }
}
