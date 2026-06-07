import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/area_type.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/presentation/widgets/plant_row.dart';
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
    final unassigned = <UserPlant>[];
    for (final p in userPlants?.values ?? const <UserPlant>[]) {
      if (p.areaId != null) {
        (plantsByArea[p.areaId!] ??= []).add(p);
      } else {
        unassigned.add(p);
      }
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
      ),
      body: areas == null || catalog == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _AreasList(
              areas: areas,
              latest: latest ?? const {},
              catalog: catalog,
              plantsByArea: plantsByArea,
              unassigned: unassigned,
              plantCatalog: plantCatalog,
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
    required this.unassigned,
    required this.plantCatalog,
  });

  final List<Area> areas;
  final Map<String, Task> latest;
  final Map<String, TaskType> catalog;
  final Map<String, List<UserPlant>> plantsByArea;
  final List<UserPlant> unassigned;
  final Map<String, Plant> plantCatalog;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (areas.isEmpty && unassigned.isEmpty) return const _GardenEmpty();

    // Flat list: section header (String or AreaType), Area row, then UserPlant rows.
    final items = <Object>[];
    // Plants added without an area (e.g. from quick-add task step 2) go first.
    if (unassigned.isNotEmpty) {
      items.add(t.areas.unassigned);
      items.addAll(unassigned);
    }
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
      // +1 for the trailing "new area" entry.
      itemCount: items.length + 1,
      itemBuilder: (context, i) {
        if (i == items.length) return const _NewAreaButton();
        final item = items[i];
        if (item is String) return _SectionHeader(label: item);
        if (item is AreaType) {
          return _SectionHeader(label: areaTypeLabel(item, context.t));
        }
        if (item is UserPlant) {
          return PlantRow(plant: item, catalog: plantCatalog);
        }
        final area = item as Area;
        return _AreaRow(
          area: area,
          lastTask: latest[area.id],
          catalog: catalog,
        );
      },
    );
  }
}

// ─── Empty state (first run) ──────────────────────────────────────────────────

class _GardenEmpty extends StatelessWidget {
  const _GardenEmpty();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 44, color: theme.colorScheme.primary)),
            const SizedBox(height: 14),
            Text(
              t.areas.empty_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t.areas.empty_body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.pushNamed('plant-add'),
              icon: const Icon(Icons.add),
              label: Text(t.areas.empty_cta_plant),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed('area-new'),
              icon: const Icon(Icons.add),
              label: Text(t.areas.empty_cta_area),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── New-area entry (quiet, always at the bottom) ─────────────────────────────

class _NewAreaButton extends StatelessWidget {
  const _NewAreaButton();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: OutlinedButton.icon(
        onPressed: () => context.pushNamed('area-new'),
        icon: const Icon(Icons.add),
        label: Text(t.areas.new_area_inline),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
  });

  final Area area;
  final Task? lastTask;
  final Map<String, TaskType> catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      _subtitle(context.t),
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

  String _subtitle(Translations t) {
    final task = lastTask;
    if (task == null) return areaTypeLabel(area.type, t);
    final type = catalog[task.taskTypeId];
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;
    return '${t.areas.last_prefix} $label · ${formatDmy(task.date.toLocal())}';
  }
}
