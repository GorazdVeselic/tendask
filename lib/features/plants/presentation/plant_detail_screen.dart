import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../application/plants_providers.dart';
import '../data/user_plants_repository.dart';
import 'plant_display.dart';
import 'widgets/area_pick_sheet.dart';

/// Read-only history of a single plant instance — the subject's home page.
class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    final plant = ref.watch(userPlantByIdProvider(id)).asData?.value;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};
    final history = ref.watch(tasksByPlantProvider(id)).asData?.value;
    final taskTypes = ref.watch(taskTypesMapProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        actions: [
          if (plant != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.pushNamed('plant-edit', pathParameters: {'id': id}),
            ),
        ],
      ),
      body: plant == null
          ? Center(child: Text(t.plant_detail.not_found))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _Hero(plant: plant, catalog: catalog, areas: areas),
                SectionLabel(t.plant_detail.history_title),
                _History(history: history, catalog: taskTypes),
              ],
            ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({
    required this.plant,
    required this.catalog,
    required this.areas,
  });

  final UserPlant plant;
  final Map<String, Plant> catalog;
  final Map<String, Area> areas;

  Future<void> _move(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final pick = await showAreaPickSheet(
      context,
      title: t.area_pick.move_title(name: userPlantLabel(plant, catalog)),
      currentAreaId: plant.areaId,
    );
    if (pick == null || !context.mounted) return;
    // Preserve the alias — moveToArea() rewrites it, so passing the current
    // value keeps a move from clearing it.
    final res = await ref
        .read(userPlantsRepositoryProvider)
        .moveToArea(
          id: plant.id,
          areaId: pick.areaId,
          personalAlias: plant.personalAlias,
        );
    if (res == PlantMoveResult.duplicate && context.mounted) {
      showTopToast(context, t.area_pick.duplicate, error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalogPlant = plant.plantId != null ? catalog[plant.plantId] : null;
    final scientific = catalogPlant?.scientificName;
    final areaName = plant.areaId != null ? areas[plant.areaId]?.name : null;
    final pillLabel = areaName != null
        ? '$areaName · ${t.plant_detail.move}'
        : t.plant_detail.assign_area;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Text(
            userPlantIcon(plant, catalog),
            style: const TextStyle(fontSize: 26),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userPlantLabel(plant, catalog),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (scientific != null)
                Text(
                  scientific,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              ActionChip(
                avatar: Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(pillLabel),
                onPressed: () => _move(context, ref),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.history, required this.catalog});

  final List<Task>? history;
  final Map<String, TaskType>? catalog;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final tasks = history;
    if (tasks == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (tasks.isEmpty) {
      return EmptyState(t.plant_detail.history_empty);
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
            _HistoryRow(task: tasks[i], catalog: catalog),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.task, required this.catalog});

  final Task task;
  final Map<String, TaskType>? catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = catalog?[task.taskTypeId];
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;
    final icon = type?.icon ?? '📋';

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: Text(
        formatDmy(task.date.toLocal()),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      // 'task-view' (top-level), not the shell-nested 'task-detail': plant-detail
      // lives above the shell, so pushing the nested route would duplicate the
      // shell page key (BUG-004).
      onTap: () =>
          context.pushNamed('task-view', pathParameters: {'id': task.id}),
    );
  }
}
