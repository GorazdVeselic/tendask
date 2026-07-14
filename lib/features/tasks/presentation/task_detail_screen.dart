import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/catalog_provider.dart';
import '../../../core/haptics.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../../supplies/application/supplies_providers.dart';
import '../application/tasks_providers.dart';
import '../harvest.dart';
import 'subject_labels.dart';
import 'task_actions.dart';
import 'task_detail_labels.dart';
import 'widgets/task_action_bar.dart';
import 'widgets/task_action_sheet.dart';
import 'widgets/task_details_card.dart';
import 'widgets/task_hero.dart';
import 'widgets/task_subjects_card.dart';
import 'widgets/task_weather_section.dart';
import 'widgets/task_yield_section.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final router = GoRouter.of(context);

    final taskAsync = ref.watch(taskByIdProvider(id));
    final catalogAsync = ref.watch(taskTypesMapProvider);
    final areasAsync = ref.watch(areasMapProvider);
    final catalog = catalogAsync.asData?.value;
    final areas = areasAsync.asData?.value;
    final repo = ref.read(tasksRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              final task = taskAsync.asData?.value;
              if (task == null) return;
              showTaskActionSheet(
                context,
                task: task,
                isHarvest: isHarvestType(catalog?[task.taskTypeId]),
              );
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(t.task_detail.not_found)),
        data: (task) {
          if (task == null) {
            return Center(child: Text(t.task_detail.not_found));
          }
          if (catalogAsync.hasError || areasAsync.hasError) {
            return Center(child: Text(t.common.load_error));
          }
          if (catalog == null || areas == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final taskType = catalog[task.taskTypeId];
          final isWaiting = task.status == TaskStatus.waiting;
          final isHarvest = isHarvestType(taskType);

          final subjects =
              ref.watch(taskSubjectsForTaskProvider(task.id)).asData?.value ??
              const [];
          final userPlants =
              ref.watch(userPlantsMapProvider).asData?.value ?? const {};
          final plantsCatalog =
              ref.watch(plantsMapProvider).asData?.value ?? const {};
          final subjectsLabel = subjectLabelsByTask(
            subjects,
            areas: areas,
            userPlants: userPlants,
            plants: plantsCatalog,
          )[task.id];

          final suppliesLabel = taskSuppliesLabel(
            ref.watch(taskSuppliesProvider(task.id)).asData?.value ?? const [],
            {
              for (final s
                  in ref.watch(suppliesListProvider).asData?.value ?? const [])
                s.id: s,
            },
          );
          final remindersLabel = taskRemindersLabel(
            ref.watch(remindersForTaskProvider(task.id)).asData?.value ??
                const [],
            t,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TaskHero(
                        task: task,
                        taskType: taskType,
                        subjectLabel: subjectsLabel,
                      ),
                      SectionLabel(
                        '${t.subject_picker.title} (${subjects.length})',
                      ),
                      TaskSubjectsCard(
                        subjects: subjects,
                        areas: areas,
                        userPlants: userPlants,
                        plants: plantsCatalog,
                      ),
                      SectionLabel(t.task_detail.section_weather),
                      TaskWeatherSection(task: task),
                      if (isHarvest && task.status == TaskStatus.done) ...[
                        SectionLabel(t.harvest.yield_section),
                        TaskYieldSection(task: task),
                      ],
                      SectionLabel(t.task_detail.section_details),
                      TaskDetailsCard(
                        task: task,
                        suppliesLabel: suppliesLabel,
                        remindersLabel: remindersLabel,
                      ),
                    ],
                  ),
                ),
              ),
              TaskActionBar(
                isWaiting: isWaiting,
                onComplete: () {
                  AppHaptics.taskCompleted();
                  unawaited(
                    completeTask(
                      context,
                      repo,
                      id,
                      harvest: isHarvest,
                    ).then((_) => router.pop()),
                  );
                },
                onPostpone: () => unawaited(repo.postponeOneDay(id)),
                onEdit: () =>
                    router.pushNamed('task-edit', pathParameters: {'id': id}),
                onDuplicate: () =>
                    unawaited(repo.duplicate(id).then((_) => router.pop())),
                onDelete: () =>
                    unawaited(repo.softDelete(id).then((_) => router.pop())),
                onRevert: () => revertTask(context, repo, task),
                onMove: () => unawaited(moveTask(context, repo, task)),
              ),
            ],
          );
        },
      ),
    );
  }
}
