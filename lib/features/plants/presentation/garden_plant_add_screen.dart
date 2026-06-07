import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/plants_providers.dart';
import 'plant_display.dart';
import 'widgets/area_pick_sheet.dart';

/// Navigation args for the plant-add screen (passed via go_router `extra`).
class PlantAddArgs {
  const PlantAddArgs({this.areaId, this.subjectMode = false});

  /// Prefilled add target (e.g. opened from an area detail). Null = no area.
  final String? areaId;

  /// True when opened from the task subject step: hides the area target row
  /// (location is irrelevant there) and just returns the created plant ids.
  final bool subjectMode;
}

/// Fixed category order for the filter chips (`all` plus catalog categories).
const _categories = [
  'all',
  'fruit_tree',
  'berries',
  'vegetable',
  'herbs',
  'ornamental',
  'lawn',
];

String _categoryLabel(String category, Translations t) => switch (category) {
      'all' => t.plants.cat_all,
      'fruit_tree' => t.plants.cat_fruit_tree,
      'berries' => t.plants.cat_berries,
      'vegetable' => t.plants.cat_vegetable,
      'herbs' => t.plants.cat_herbs,
      'ornamental' => t.plants.cat_ornamental,
      'lawn' => t.plants.cat_lawn,
      _ => category,
    };

/// One plant added during this session — kept so the footer can show what was
/// added, catalog rows can show a ✓, and the created ids can be returned/undone.
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

  @override
  void initState() {
    super.initState();
    _targetAreaId = widget.args.areaId;
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
    final id = await ref.read(userPlantsRepositoryProvider).create(
          userId: ref.read(authServiceProvider).userId,
          areaId: _targetAreaId,
          plantId: plantId,
          customName: customName,
        );
    if (!mounted) return;
    setState(() => _added.add(_Added(id, plantId, label)));
  }

  Future<void> _undo() async {
    if (_added.isEmpty) return;
    final last = _added.last;
    await ref.read(userPlantsRepositoryProvider).softDelete(last.id);
    if (!mounted) return;
    setState(() => _added.removeLast());
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
    // when the area is chosen after some taps. Rows have no alias yet.
    final repo = ref.read(userPlantsRepositoryProvider);
    for (final a in _added) {
      await repo.update(id: a.id, areaId: pick.areaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final plants = ref.watch(plantsListProvider).asData?.value;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final recentIds = ref.watch(recentPlantsProvider).asData?.value ?? const [];

    final normQuery = _query.trim().toLowerCase();
    final results = plants == null
        ? const <Plant>[]
        : plants
            .where((p) => _category == 'all' || p.category == _category)
            .where((p) => plantMatchesQuery(p, normQuery))
            .toList();
    final addedPlantIds = {for (final a in _added) ?a.plantId};

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
          Expanded(
            child: plants == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Categories
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final c in _categories)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(_categoryLabel(c, t)),
                                  selected: c == _category,
                                  onSelected: (_) =>
                                      setState(() => _category = c),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Frequent (recently used)
                      if (recentIds.isNotEmpty && normQuery.isEmpty) ...[
                        SectionLabel(t.plants.frequent),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final id in recentIds)
                              if (catalog[id] case final p?)
                                ActionChip(
                                  avatar: Text(p.icon ?? '🌿',
                                      style: const TextStyle(fontSize: 16)),
                                  label: Text(catalogLabel(p.labels)),
                                  onPressed: () => _create(
                                      plantId: p.id, label: catalogLabel(p.labels)),
                                ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      // From catalog header + collapsible search
                      Row(
                        children: [
                          Expanded(child: SectionLabel(t.plants.from_catalog)),
                          IconButton(
                            icon: Icon(_searchExpanded
                                ? Icons.search_off
                                : Icons.search),
                            color: theme.colorScheme.primary,
                            onPressed: () {
                              setState(() {
                                _searchExpanded = !_searchExpanded;
                                if (!_searchExpanded) {
                                  _query = '';
                                  _searchController.clear();
                                }
                              });
                            },
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
                      if (results.isNotEmpty)
                        Card(
                          child: Column(
                            children: [
                              for (var i = 0; i < results.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    indent: 56,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                _CatalogAddRow(
                                  plant: results[i],
                                  added: addedPlantIds.contains(results[i].id),
                                  onAdd: () => _create(
                                    plantId: results[i].id,
                                    label: catalogLabel(results[i].labels),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      // Custom entry
                      if (normQuery.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _CustomEntry(
                          query: _query.trim(),
                          onAdd: (name) =>
                              _create(customName: name, label: name),
                        ),
                      ],
                      // Optional add target — last, de-emphasised
                      if (!widget.args.subjectMode) ...[
                        const SizedBox(height: 8),
                        SectionLabel(t.plants.add_to_label),
                        _TargetRow(
                          areaId: _targetAreaId,
                          areas:
                              ref.watch(areasMapProvider).asData?.value ?? const {},
                          onTap: _changeTarget,
                        ),
                      ],
                    ],
                  ),
          ),
          if (_added.isNotEmpty) _AddedBar(added: _added, onUndo: _undo, onDone: () => context.pop(_createdIds)),
        ],
      ),
    );
  }
}

// ─── Catalog row (instant add) ───────────────────────────────────────────────

class _CatalogAddRow extends StatelessWidget {
  const _CatalogAddRow({
    required this.plant,
    required this.added,
    required this.onAdd,
  });

  final Plant plant;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = plant.scientificName != null
        ? '${plant.scientificName} · ${plant.category}'
        : plant.category;
    return ListTile(
      leading: Text(plant.icon ?? '🌿', style: const TextStyle(fontSize: 22)),
      title: Text(catalogLabel(plant.labels), style: theme.textTheme.bodyMedium),
      subtitle: Text(sub, style: theme.textTheme.bodySmall),
      trailing: Icon(added ? Icons.check_circle : Icons.add_circle_outline,
          color: theme.colorScheme.primary),
      onTap: onAdd,
    );
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
            SectionLabel(t.plants.not_found,
                padding: const EdgeInsets.only(bottom: 6)),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onAdd(query),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  t.plants.custom_add(q: query),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.plants.custom_private,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Optional add target ──────────────────────────────────────────────────────

class _TargetRow extends StatelessWidget {
  const _TargetRow({
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
    final name = areaId != null ? areas[areaId]?.name : null;
    return Card(
      child: ListTile(
        leading: Icon(Icons.place_outlined,
            color: theme.colorScheme.onSurfaceVariant),
        title: Text(name ?? t.area_pick.none),
        trailing: Text(
          t.plant_detail.move,
          style: TextStyle(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }
}

// ─── Sticky "added" footer ────────────────────────────────────────────────────

class _AddedBar extends StatelessWidget {
  const _AddedBar({
    required this.added,
    required this.onUndo,
    required this.onDone,
  });

  final List<_Added> added;
  final VoidCallback onUndo;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final names = [for (final a in added) a.label].reversed.join(' · ');
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(t.plants.added_count(n: added.length),
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(names,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall),
                  ),
                  TextButton(onPressed: onUndo, child: Text(t.plants.undo)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onDone, child: Text(t.plants.done)),
            ),
          ],
        ),
      ),
    );
  }
}
