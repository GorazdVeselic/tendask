import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/area_type.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/presentation/widgets/plant_row.dart';
import '../../supplies/presentation/recipe_edit_sheet.dart';
import '../../supplies/presentation/supply_edit_sheet.dart';
import '../../supplies/presentation/widgets/supply_list_views.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';

// Garden hub: areas plus (when supplies are enabled) the stock and recipe
// segments, mirroring the journal screen's in-screen segmented switch.
enum _Section { areas, supplies, recipes }

class AreasScreen extends ConsumerStatefulWidget {
  const AreasScreen({super.key});

  @override
  ConsumerState<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends ConsumerState<AreasScreen> {
  _Section _section = _Section.areas;

  // The garden FAB adds this segment's primary entity: a plant on the areas
  // segment (adding an area stays a quieter entry at the list's bottom), a
  // supply or a recipe on the others.
  void _add() => switch (_section) {
    _Section.areas => context.pushNamed('plant-add'),
    _Section.supplies => showSupplyEditSheet(context),
    _Section.recipes => showRecipeEditSheet(context),
  };

  String _fabLabel(Translations t) => switch (_section) {
    _Section.areas => t.areas.fab_plant,
    _Section.supplies => t.supplies.fab_new,
    _Section.recipes => t.recipes.fab_new,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.areas.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.areas.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(_fabLabel(t)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: kSuppliesEnabled
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: SegmentedButton<_Section>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: _Section.areas,
                        label: Text(t.areas.seg_areas),
                      ),
                      ButtonSegment(
                        value: _Section.supplies,
                        label: Text(t.supplies.seg_supplies),
                      ),
                      ButtonSegment(
                        value: _Section.recipes,
                        label: Text(t.supplies.seg_recipes),
                      ),
                    ],
                    selected: {_section},
                    onSelectionChanged: (s) =>
                        setState(() => _section = s.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                Expanded(
                  child: switch (_section) {
                    _Section.areas => const _AreasBody(),
                    _Section.supplies => const SupplyListView(),
                    _Section.recipes => const RecipeListView(),
                  },
                ),
              ],
            )
          : const _AreasBody(),
    );
  }
}

// ─── Areas body (the garden list; own loader/empty state) ─────────────────────

class _AreasBody extends ConsumerWidget {
  const _AreasBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    if (areas == null || catalog == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return _AreasList(
      areas: areas,
      latest: latest ?? const {},
      catalog: catalog,
      plantsByArea: plantsByArea,
      unassigned: unassigned,
      plantCatalog: plantCatalog,
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

    // Flat list. Hierarchy reads top-down: area-type section label → area header
    // → a card holding that area's plants. Plants without an area come first,
    // under their own label, in a card with no header.
    final items = <Object>[];
    if (unassigned.isNotEmpty) {
      items.add(t.areas.unassigned);
      items.add(_PlantGroup(unassigned));
    }
    for (final type in AreaType.values) {
      final inType = areas.where((a) => a.type == type).toList();
      if (inType.isEmpty) continue;
      items.add(type);
      for (final area in inType) {
        items.add(area);
        final plants = plantsByArea[area.id] ?? const <UserPlant>[];
        if (plants.isNotEmpty) items.add(_PlantGroup(plants));
      }
    }

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        // +1 for the trailing "new area" entry.
        itemCount: items.length + 1,
        itemBuilder: (context, i) {
          if (i == items.length) return const _NewAreaButton();
          final item = items[i];
          if (item is String) {
            return SectionLabel(item, padding: _kSectionPad);
          }
          if (item is AreaType) {
            return SectionLabel(
              areaTypeLabel(item, context.t),
              padding: _kSectionPad,
            );
          }
          if (item is _PlantGroup) {
            return _PlantGroupCard(plants: item.plants, catalog: plantCatalog);
          }
          final area = item as Area;
          return _AreaHeader(
            area: area,
            lastTask: latest[area.id],
            catalog: catalog,
          );
        },
      ),
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
            Text(
              '🌱',
              style: TextStyle(fontSize: 44, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              t.areas.empty_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.areas.empty_body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

// Section headers in the garden list keep the list's 16px horizontal indent.
const _kSectionPad = EdgeInsets.fromLTRB(16, 16, 16, 4);

// ─── Area header (the group's parent line; plants render in a card beneath) ────

class _AreaHeader extends StatelessWidget {
  const _AreaHeader({
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
    return InkWell(
      onTap: () =>
          context.pushNamed('area-detail', pathParameters: {'id': area.id}),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                areaTypeIcon(area.type),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
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

// ─── Plant group (an area's plants, or the unassigned ones, in one card) ───────

/// Marker item in the flat list carrying the plants to render together.
class _PlantGroup {
  const _PlantGroup(this.plants);
  final List<UserPlant> plants;
}

class _PlantGroupCard extends StatelessWidget {
  const _PlantGroupCard({required this.plants, required this.catalog});

  final List<UserPlant> plants;
  final Map<String, Plant> catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < plants.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
            PlantRow(plant: plants[i], catalog: catalog),
          ],
        ],
      ),
    );
  }
}
