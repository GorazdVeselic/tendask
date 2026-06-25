import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/catalog_sort.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/plant_category.dart';
import '../../../core/widgets/removable_chip.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/plants_providers.dart';
import '../data/user_plants_repository.dart';
import 'plant_display.dart';
import 'widgets/area_pick_sheet.dart';
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

/// One plant added during this session — kept so the footer can show what was
/// added, catalog rows can show a ✓, and the created ids can be returned/removed.
class _Added {
  const _Added(this.id, this.plantId, this.label);
  final String id;
  final String? plantId;
  final String label;
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
  final List<_Added> _added = [];

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
    setState(() => _added.add(_Added(id, plantId, label)));
  }

  /// Tap on a catalog/frequent plant: toggle its membership of the target. A
  /// member (added this session OR already in the target area) is removed;
  /// otherwise it is added. Custom entries (no plantId) never reach here.
  Future<void> _toggle(Plant plant) async {
    final member = _memberFor(plant.id);
    if (member != null) {
      await _removeMember(member);
    } else {
      await _create(plantId: plant.id, label: catalogLabel(plant.labels));
    }
  }

  /// The instance representing [plantId] in the current target — a session add
  /// or, when a real area is targeted, a plant already living there.
  _Added? _memberFor(String plantId) {
    for (final a in _added) {
      if (a.plantId == plantId) return a;
    }
    if (!widget.args.subjectMode) {
      final map = ref.read(userPlantsMapProvider).asData?.value ?? const {};
      final catalog = ref.read(plantsMapProvider).asData?.value ?? const {};
      for (final p in map.values) {
        if (p.areaId == _targetAreaId && p.plantId == plantId) {
          return _Added(p.id, p.plantId, userPlantLabel(p, catalog));
        }
      }
    }
    return null;
  }

  Future<void> _removeMember(_Added member) async {
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
    final dropped = <_Added>[];
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

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final plants = ref.watch(plantsListProvider).asData?.value;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};

    final normQuery = _query.trim().toLowerCase();
    final results = plants == null
        ? const <Plant>[]
        : sortedByLabel(
            plants
                .where(
                  (p) =>
                      _category == 'all' ||
                      coarsePlantCategory(p.category) == _category,
                )
                .where((p) => plantMatchesQuery(p, normQuery)),
            (p) => catalogLabel(p.labels),
          );
    // Members = added this session, plus (in garden mode) every plant already
    // in the current target bucket — a real area OR "no area" (null) — so the
    // footer, counter, ✓ and remove cover the bucket's whole contents.
    final userPlantsMap =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};
    final managesArea = !widget.args.subjectMode;
    final members = <_Added>[
      ..._added,
      if (managesArea)
        for (final p in userPlantsMap.values)
          if (p.areaId == _targetAreaId && _added.every((a) => a.id != p.id))
            _Added(p.id, p.plantId, userPlantLabel(p, catalog)),
    ];
    final selectedIds = {for (final m in members) ?m.plantId};

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
          // Add target — pinned at the top so it's always visible (the catalog
          // list below can grow long).
          if (!widget.args.subjectMode)
            _AreaBar(
              areaId: _targetAreaId,
              areas: ref.watch(areasMapProvider).asData?.value ?? const {},
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 40,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (final c in kPlantCategories)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(plantCategoryLabel(c, t)),
                                          selected: c == _category,
                                          onSelected: (_) =>
                                              setState(() => _category = c),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_recentIds.isNotEmpty &&
                                  normQuery.isEmpty) ...[
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
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
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
                                  Expanded(
                                    child: SectionLabel(t.plants.from_catalog),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _searchExpanded
                                          ? Icons.search_off
                                          : Icons.search,
                                    ),
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
                                    onChanged: (v) =>
                                        setState(() => _query = v),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList.separated(
                          itemCount: results.length,
                          itemBuilder: (_, i) => PlantSelectRow(
                            icon: results[i].icon ?? '🌿',
                            title: catalogLabel(results[i].labels),
                            subtitle: plantCategoryLabel(
                              coarsePlantCategory(results[i].category),
                              t,
                            ),
                            selected: selectedIds.contains(results[i].id),
                            onTap: () => _toggle(results[i]),
                          ),
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 56,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      if (normQuery.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverToBoxAdapter(
                            child: _CustomEntry(
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
            _AddedBar(
              added: members,
              onRemove: _removeMember,
              onDone: () => context.pop(_createdIds),
            ),
        ],
      ),
    );
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
}

// ─── Custom entry ─────────────────────────────────────────────────────────────

class _CustomEntry extends StatelessWidget {
  const _CustomEntry({required this.query, required this.onAdd});

  final String query;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              t.plants.not_found,
              padding: const EdgeInsets.only(bottom: 6),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onAdd(query),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  t.plants.custom_add(q: query),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.plants.custom_private,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Optional add target ──────────────────────────────────────────────────────

class _AreaBar extends StatelessWidget {
  const _AreaBar({
    required this.areaId,
    required this.areas,
    required this.onTap,
  });

  final String? areaId;
  final Map<String, Area> areas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = areaId != null ? areas[areaId]?.name : null;
    return Material(
      color: cs.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.plants.add_to_label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name ?? t.area_pick.none,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    t.plants.choose_area,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}

// ─── Sticky "added" footer ────────────────────────────────────────────────────

class _AddedBar extends StatelessWidget {
  const _AddedBar({
    required this.added,
    required this.onRemove,
    required this.onDone,
  });

  final List<_Added> added;
  final void Function(_Added) onRemove;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Newest first so the latest add sits at the front without scrolling.
    final items = added.reversed.toList();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${added.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => RemovableChip(
                        label: items[i].label,
                        onRemove: () => onRemove(items[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDone,
                child: Text(t.plants.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
