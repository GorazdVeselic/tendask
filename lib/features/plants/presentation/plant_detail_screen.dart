import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../application/plants_providers.dart';
import 'plant_display.dart';

/// Read-only history of a single plant instance — the subject's home page.
class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

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
                _Hero(plant: plant, catalog: catalog, areas: areas, theme: theme),
                const SizedBox(height: 16),
                Text(
                  t.plant_detail.history_title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _History(
                  history: history,
                  catalog: taskTypes,
                  t: t,
                  theme: theme,
                ),
              ],
            ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.plant,
    required this.catalog,
    required this.areas,
    required this.theme,
  });

  final UserPlant plant;
  final Map<String, Plant> catalog;
  final Map<String, Area> areas;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final catalogPlant = plant.plantId != null ? catalog[plant.plantId] : null;
    final scientific = catalogPlant?.scientificName;
    final areaName = plant.areaId != null ? areas[plant.areaId]?.name : null;
    final sub = [
      ?scientific,
      if (areaName != null) '🪴 $areaName',
    ].join(' · ');

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Text(userPlantIcon(plant, catalog),
              style: const TextStyle(fontSize: 26)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userPlantLabel(plant, catalog),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({
    required this.history,
    required this.catalog,
    required this.t,
    required this.theme,
  });

  final List<Task>? history;
  final Map<String, TaskType>? catalog;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final tasks = history;
    if (tasks == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (tasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            t.plant_detail.history_empty,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
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
            _HistoryRow(task: tasks[i], catalog: catalog, theme: theme),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.task,
    required this.catalog,
    required this.theme,
  });

  final Task task;
  final Map<String, TaskType>? catalog;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final type = catalog?[task.taskTypeId];
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;
    final icon = type?.icon ?? '📋';

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: Text(
        formatDmy(task.date.toLocal()),
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () =>
          context.pushNamed('task-detail', pathParameters: {'id': task.id}),
    );
  }
}
