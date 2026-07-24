import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../application/tasks_providers.dart';
import '../harvest.dart';
import 'subject_labels.dart';
import 'task_actions.dart';
import 'task_day_groups.dart';
import 'widgets/task_list_row.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

    final pending = ref.watch(pendingTasksProvider).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final areas = ref.watch(areasMapProvider).asData?.value;
    final reminderTaskIds =
        ref.watch(taskIdsWithRemindersProvider).asData?.value ?? const {};
    final repo = ref.read(tasksRepositoryProvider);

    final subjectLabels = subjectLabelsByTask(
      ref.watch(allTaskSubjectsProvider).asData?.value ?? const [],
      areas: areas ?? const {},
      userPlants: ref.watch(userPlantsMapProvider).asData?.value ?? const {},
      plants: ref.watch(plantsMapProvider).asData?.value ?? const {},
    );

    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.tasks_list.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.tasks_list.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: pending == null || catalog == null || areas == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _TasksList(
              items: buildTaskListItems(pending, now),
              now: now,
              catalog: catalog,
              subjectLabels: subjectLabels,
              reminderTaskIds: reminderTaskIds,
              onComplete: (id, harvest) {
                AppHaptics.taskCompleted();
                unawaited(completeTask(context, repo, id, harvest: harvest));
              },
              onPostpone: (id) => repo.postponeOneDay(id),
              onDuplicate: (id) => repo.duplicate(id),
              onDelete: (id) => repo.softDelete(id),
            ),
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({
    required this.items,
    required this.now,
    required this.catalog,
    required this.subjectLabels,
    required this.reminderTaskIds,
    required this.onComplete,
    required this.onPostpone,
    required this.onDuplicate,
    required this.onDelete,
  });

  final List<TaskListItem> items;
  final DateTime now;
  final Map<String, TaskType> catalog;
  final Map<String, String> subjectLabels;
  final Set<String> reminderTaskIds;
  final void Function(String id, bool harvest) onComplete;
  final void Function(String id) onPostpone;
  final void Function(String id) onDuplicate;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (items.isEmpty) return EmptyState(t.tasks_list.empty);

    // Opening one row's actions auto-closes any other open row.
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length,
        itemBuilder: (context, i) => switch (items[i]) {
          TaskSectionItem(:final group) => SectionLabel(
            taskGroupLabel(group, t),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          ),
          TaskRowItem(:final task, :final group) => TaskListRow(
            task: task,
            taskType: catalog[task.taskTypeId],
            subjectLabel: subjectLabels[task.id],
            hasReminder: reminderTaskIds.contains(task.id),
            group: group,
            statusText: taskStatusText(group, task.date, now, t),
            onComplete: () =>
                onComplete(task.id, isHarvestType(catalog[task.taskTypeId])),
            onPostpone: () => onPostpone(task.id),
            onEdit: () =>
                context.pushNamed('task-edit', pathParameters: {'id': task.id}),
            onDuplicate: () => onDuplicate(task.id),
            onDelete: () => onDelete(task.id),
          ),
        },
      ),
    );
  }
}
