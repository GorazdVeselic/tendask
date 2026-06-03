import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/area_type.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/presentation/plant_display.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';

class AreasScreen extends ConsumerWidget {
  const AreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

    final areas = ref.watch(areasListProvider).asData?.value;
    final latest = ref.watch(latestTaskPerAreaProvider).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final userPlants = ref.watch(userPlantsMapProvider).asData?.value;
    final plantCatalog = ref.watch(plantsMapProvider).asData?.value ?? const {};

    final plantsByArea = <String, List<UserPlant>>{};
    for (final p in userPlants?.values ?? const <UserPlant>[]) {
      if (p.areaId != null) (plantsByArea[p.areaId!] ??= []).add(p);
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.areas.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              t.areas.subtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed('area-new'),
          ),
        ],
      ),
      body: areas == null || catalog == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _AreasList(
              areas: areas,
              latest: latest ?? const {},
              catalog: catalog,
              plantsByArea: plantsByArea,
              plantCatalog: plantCatalog,
              t: t,
              theme: theme,
            ),
    );
  }
}

// ─── List ────────────────────────────────────────────────────────────────────

class _AreasList extends StatelessWidget {
  const _AreasList({
    required this.areas,
    required this.latest,
    required this.catalog,
    required this.plantsByArea,
    required this.plantCatalog,
    required this.t,
    required this.theme,
  });

  final List<Area> areas;
  final Map<String, Task> latest;
  final Map<String, TaskType> catalog;
  final Map<String, List<UserPlant>> plantsByArea;
  final Map<String, Plant> plantCatalog;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (areas.isEmpty) return EmptyState(t.areas.empty);

    // Flat list: AreaType (section header), Area (row), then its UserPlant rows.
    final items = <Object>[];
    for (final type in AreaType.values) {
      final inType = areas.where((a) => a.type == type).toList();
      if (inType.isEmpty) continue;
      items.add(type);
      for (final area in inType) {
        items.add(area);
        items.addAll(plantsByArea[area.id] ?? const []);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is AreaType) {
          return _SectionHeader(label: areaTypeLabel(item, t), theme: theme);
        }
        if (item is UserPlant) {
          return _PlantRow(
            plant: item,
            catalog: plantCatalog,
            theme: theme,
          );
        }
        final area = item as Area;
        return _AreaRow(
          area: area,
          lastTask: latest[area.id],
          catalog: catalog,
          t: t,
          theme: theme,
        );
      },
    );
  }
}

// ─── Plant row (under its area) ───────────────────────────────────────────────

class _PlantRow extends StatelessWidget {
  const _PlantRow({
    required this.plant,
    required this.catalog,
    required this.theme,
  });

  final UserPlant plant;
  final Map<String, Plant> catalog;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 16),
      child: ListTile(
        dense: true,
        leading: Text(userPlantIcon(plant, catalog),
            style: const TextStyle(fontSize: 20)),
        title: Text(userPlantLabel(plant, catalog),
            style: theme.textTheme.bodyMedium),
        trailing: Icon(Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant, size: 20),
        onTap: () =>
            context.pushNamed('plant-detail', pathParameters: {'id': plant.id}),
      ),
    );
  }
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

// ─── Area row ────────────────────────────────────────────────────────────────

class _AreaRow extends StatelessWidget {
  const _AreaRow({
    required this.area,
    required this.lastTask,
    required this.catalog,
    required this.t,
    required this.theme,
  });

  final Area area;
  final Task? lastTask;
  final Map<String, TaskType> catalog;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.pushNamed(
          'area-detail',
          pathParameters: {'id': area.id},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(areaTypeIcon(area.type),
                    style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _subtitle(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final task = lastTask;
    if (task == null) return areaTypeLabel(area.type, t);
    final type = catalog[task.taskTypeId];
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;
    return '${t.areas.last_prefix} $label · ${formatDmy(task.date.toLocal())}';
  }
}
