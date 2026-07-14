import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/application/plants_providers.dart';
import '../../supplies/presentation/recipe_edit_sheet.dart';
import '../../supplies/presentation/supply_edit_sheet.dart';
import '../../supplies/presentation/widgets/supply_list_views.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';
import 'garden_items.dart';
import 'widgets/area_header.dart';
import 'widgets/garden_empty.dart';
import 'widgets/plant_group_card.dart';

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

    if (areas == null || catalog == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final grouped = groupPlantsByArea(userPlants?.values ?? const <UserPlant>[]);
    final items = buildGardenItems(
      areas: areas,
      plantsByArea: grouped.byArea,
      unassigned: grouped.unassigned,
      latestTaskPerArea: latest ?? const {},
    );
    if (items.isEmpty) return const GardenEmpty();

    return _GardenList(items: items, catalog: catalog, plants: plantCatalog);
  }
}

// ─── List ────────────────────────────────────────────────────────────────────

class _GardenList extends StatelessWidget {
  const _GardenList({
    required this.items,
    required this.catalog,
    required this.plants,
  });

  final List<GardenItem> items;
  final Map<String, TaskType> catalog;
  final Map<String, Plant> plants;

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        // +1 for the trailing "new area" entry.
        itemCount: items.length + 1,
        itemBuilder: (context, i) {
          if (i == items.length) return const _NewAreaButton();
          return switch (items[i]) {
            GardenUnassignedSection() => SectionLabel(
              context.t.areas.unassigned,
              padding: _kSectionPad,
            ),
            GardenTypeSection(:final type) => SectionLabel(
              areaTypeLabel(type, context.t),
              padding: _kSectionPad,
            ),
            GardenAreaItem item => AreaHeader(item: item, catalog: catalog),
            GardenPlantsItem(plants: final group) => PlantGroupCard(
              plants: group,
              catalog: plants,
            ),
          };
        },
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
