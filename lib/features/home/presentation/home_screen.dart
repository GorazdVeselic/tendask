import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/section_label.dart';
import '../../../features/areas/application/areas_providers.dart';
import '../../../features/auth/presentation/widgets/account_avatar_button.dart';
import '../../../features/plants/application/plants_providers.dart';
import '../../../features/tasks/application/tasks_providers.dart';
import '../../../features/tasks/presentation/subject_labels.dart';
import '../../../features/weather/application/weather_service.dart';
import '../../../i18n/translations.g.dart';
import 'home_buckets.dart';
import 'widgets/dashboard_hint.dart';
import 'widgets/home_task_list.dart';
import 'widgets/home_weather_section.dart';
import 'widgets/task_banner.dart';

/// How many completed tasks the "recent" card shows.
const _kRecentCount = 3;

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
              formatDmy(now),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          const AccountAvatarButton(),
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
    final cs = Theme.of(context).colorScheme;
    final reminderTaskIds =
        ref.watch(taskIdsWithRemindersProvider).asData?.value ?? const {};
    final subjectLabels = subjectLabelsByTask(
      ref.watch(allTaskSubjectsProvider).asData?.value ?? const [],
      areas: ref.watch(areasMapProvider).asData?.value ?? const {},
      userPlants: ref.watch(userPlantsMapProvider).asData?.value ?? const {},
      plants: ref.watch(plantsMapProvider).asData?.value ?? const {},
    );

    final buckets = bucketPendingTasks(pending.asData?.value ?? const [], now);
    final recentTasks =
        completed.asData?.value.take(_kRecentCount).toList() ?? const <Task>[];

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
            const HomeWeatherSection(),
            const SizedBox(height: 16),
            if (buckets.overdue.isNotEmpty) ...[
              TaskBanner(
                label: t.home.overdue_banner(n: buckets.overdue.length),
                icon: Icons.warning_amber_rounded,
                background: cs.errorContainer,
                foreground: cs.onErrorContainer,
                tasks: buckets.overdue,
                catalog: catalog,
                now: now,
                subjectLabels: subjectLabels,
                isOverdue: true,
              ),
              const SizedBox(height: 16),
            ],
            if (buckets.upcoming.isNotEmpty) ...[
              TaskBanner(
                label: t.home.upcoming_banner(n: buckets.upcoming.length),
                icon: Icons.event_outlined,
                background: cs.primaryContainer,
                foreground: cs.onPrimaryContainer,
                tasks: buckets.upcoming,
                catalog: catalog,
                now: now,
                subjectLabels: subjectLabels,
                reminderTaskIds: reminderTaskIds,
                isUpcoming: true,
              ),
              const SizedBox(height: 16),
            ],
            SectionLabel(
              t.home.today,
              padding: const EdgeInsets.only(bottom: 8),
            ),
            if (buckets.today.isEmpty)
              DashboardHint(t.home.no_tasks_today)
            else
              HomeTaskList(
                tasks: buckets.today,
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
              DashboardHint(t.home.no_recent)
            else
              HomeTaskList(
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
