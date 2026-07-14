import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/plant_category.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/plants_providers.dart';
import '../data/user_plants_repository.dart';
import 'plant_picker_view.dart';
import 'widgets/area_pick_sheet.dart';
import 'widgets/plant_added_bar.dart';
import 'widgets/plant_area_bar.dart';
import 'widgets/plant_custom_entry.dart';
import 'widgets/plant_select_row.dart';

/// Navigation args for the plant-add screen (passed via go_router `extra`).
class PlantAddArgs {
  const PlantAddArgs({this.areaId, this.subjectMode = false});

  /// Prefilled add target (e.g. opened from an area detail). Null = no area.
  final String? areaId;

  /// True when opened from the task subject step: hides the area target row
  /// (location is irrelevant there) and just returns the created plant ids.
  final bool subjectMode;
}

/// Garden plant-add: one screen, tap = added immediately, add as many as you
/// like, then "Done". Area is optional and lives at the bottom.
class GardenPlantAddScreen extends ConsumerStatefulWidget {
  const GardenPlantAddScreen({required this.args, super.key});

  final PlantAddArgs args;

  @override
  ConsumerState<GardenPlantAddScreen> createState() =>
      _GardenPlantAddScreenState();
}

class _GardenPlantAddScreenState extends ConsumerState<GardenPlantAddScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'all';
  bool _searchExpanded = false;
  String? _targetAreaId;
  final List<PickedPlant> _added = [];

  // Snapshot taken once on open: the "Frequent" row stays stable through the
  // session instead of re-querying (and flickering) on every add.
  List<String> _recentIds = const [];

  @override
  void initState() {
    super.initState();
    _targetAreaId = widget.args.areaId;
    ref.read(userPlantsRepositoryProvider).recentPlantIds().then((ids) {
      if (mounted) setState(() => _recentIds = ids);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _createdIds => [for (final a in _added) a.id];

  bool get _managesArea => !widget.args.subjectMode;

  /// The target's contents as of now. Callbacks read (rather than watch) — the
  /// build pass computes the same from its watched values.
  List<PickedPlant> _members({
    Map<String, UserPlant>? userPlants,
    Map<String, Plant>? catalog,
  }) => pickerMembers(
    added: _added,
    userPlants:
        (userPlants ?? ref.read(userPlantsMapProvider).asData?.value ?? const {})
            .values,
    catalog: catalog ?? ref.read(plantsMapProvider).asData?.value ?? const {},
    targetAreaId: _targetAreaId,
    managesArea: _managesArea,
  );

  Future<void> _create({
    String? plantId,
    String? customName,
    required String label,
  }) async {
    final id = await ref
        .read(userPlantsRepositoryProvider)
        .create(
          userId: ref.read(authServiceProvider).userId,
          areaId: _targetAreaId,
          plantId: plantId,
          customName: customName,
        );
    if (!mounted) return;
    setState(() => _added.add(PickedPlant(id, plantId, label)));
  }

  /// Tap on a catalog/frequent plant: toggle its membership of the target. A
  /// member (added this session OR already in the target area) is removed;
  /// otherwise it is added. Custom entries (no plantId) never reach here.
  Future<void> _toggle(Plant plant) async {
    final member = memberFor(_members(), plant.id);
    if (member != null) {
      await _removeMember(member);
    } else {
      await _create(plantId: plant.id, label: catalogLabel(plant.labels));
    }
  }

  Future<void> _removeMember(PickedPlant member) async {
    await ref.read(userPlantsRepositoryProvider).softDelete(member.id);
    if (!mounted) return;
    setState(() => _added.removeWhere((a) => a.id == member.id));
  }

  Future<void> _changeTarget() async {
    final t = context.t;
    final pick = await showAreaPickSheet(
      context,
      title: t.area_pick.choose_title,
      currentAreaId: _targetAreaId,
    );
    if (pick == null || !mounted) return;
    setState(() => _targetAreaId = pick.areaId);
    // Re-parent already-added rows so "I'm adding these to bed X" holds even
    // when the area is chosen after some taps. Rows have no alias yet. If the
    // new area already has the species, the fresh instance is redundant — drop
    // it instead of leaving a duplicate behind.
    final repo = ref.read(userPlantsRepositoryProvider);
    final dropped = <PickedPlant>[];
    for (final a in _added) {
      final res = await repo.moveToArea(id: a.id, areaId: pick.areaId);
      if (res == PlantMoveResult.duplicate) {
        await repo.softDelete(a.id);
        dropped.add(a);
      }
    }
    if (dropped.isNotEmpty && mounted) {
      setState(() => _added.removeWhere(dropped.contains));
    }
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
      if (!_searchExpanded) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final plants = ref.watch(plantsListProvider).asData?.value;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areasMap = ref.watch(areasMapProvider).asData?.value ?? const {};
    final userPlantsMap =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};

    final results = filterCatalog(
      plants ?? const [],
      category: _category,
      query: _query,
    );
    final split = splitByRelevance(
      results,
      _targetAreaId != null ? areasMap[_targetAreaId]?.type : null,
    );
    final members = _members(userPlants: userPlantsMap, catalog: catalog);
    final selectedIds = {for (final m in members) ?m.plantId};
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(_createdIds),
        ),
        title: Text(t.plants.add_title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_managesArea)
            PlantAreaBar(
              areaId: _targetAreaId,
              areas: areasMap,
              onTap: _changeTarget,
            ),
          Expanded(
            child: plants == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                // Sliver list so only visible catalog rows build — the seed has
                // ~130 plants and an eager Column rebuilt all of them on every
                // toggle, which is what felt like a freeze on open.
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: _header(catalog, selectedIds, hasQuery),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          split.softSplit ? 0 : 16,
                        ),
                        sliver: _catalogSliver(split.first, selectedIds),
                      ),
                      if (split.softSplit) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          sliver: SliverToBoxAdapter(
                            child: SectionLabel(t.plants.less_likely),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: _catalogSliver(split.other, selectedIds),
                        ),
                      ],
                      if (hasQuery)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverToBoxAdapter(
                            child: PlantCustomEntry(
                              query: _query.trim(),
                              onAdd: (name) =>
                                  _create(customName: name, label: name),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          if (members.isNotEmpty)
            PlantAddedBar(
              added: members,
              onRemove: _removeMember,
              onDone: () => context.pop(_createdIds),
            ),
        ],
      ),
    );
  }

  /// Category chips, the frequent row and the (collapsible) search field.
  Widget _header(
    Map<String, Plant> catalog,
    Set<String> selectedIds,
    bool hasQuery,
  ) {
    final t = context.t;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final c in kPlantCategories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(plantCategoryLabel(c, t)),
                    selected: c == _category,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ),
            ],
          ),
        ),
        if (_recentIds.isNotEmpty && !hasQuery) ...[
          SectionLabel(t.plants.frequent),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final id in _recentIds)
                if (catalog[id] case final p?)
                  FilterChip(
                    avatar: Text(
                      p.icon ?? '🌿',
                      style: const TextStyle(fontSize: 16),
                    ),
                    label: Text(catalogLabel(p.labels)),
                    selected: selectedIds.contains(p.id),
                    onSelected: (_) => _toggle(p),
                  ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(child: SectionLabel(t.plants.from_catalog)),
            IconButton(
              icon: Icon(_searchExpanded ? Icons.search_off : Icons.search),
              color: theme.colorScheme.primary,
              onPressed: _toggleSearch,
            ),
          ],
        ),
        if (_searchExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: t.plants.search_hint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
      ],
    );
  }

  // Lazy catalog list; split into a relevant and a "less likely" group for T4.
  Widget _catalogSliver(List<Plant> rows, Set<String> selectedIds) {
    final t = context.t;
    final theme = Theme.of(context);
    return SliverList.separated(
      itemCount: rows.length,
      itemBuilder: (_, i) => PlantSelectRow(
        icon: rows[i].icon ?? '🌿',
        title: catalogLabel(rows[i].labels),
        subtitle: plantCategoryLabel(coarsePlantCategory(rows[i].category), t),
        selected: selectedIds.contains(rows[i].id),
        onTap: () => _toggle(rows[i]),
      ),
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 56,
        color: theme.colorScheme.outlineVariant,
      ),
    );
  }
}
