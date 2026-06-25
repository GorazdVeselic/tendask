import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/auth/auth_service.dart';
import '../../../../../core/catalog_labels.dart';
import '../../../../../core/catalog_relevance.dart';
import '../../../../../core/catalog_sort.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/database/catalog_provider.dart';
import '../../../../../core/plant_category.dart';
import '../../../../../core/widgets/removable_chip.dart';
import '../../../../../core/widgets/section_label.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../../areas/application/areas_providers.dart';
import '../../../../areas/presentation/area_type_display.dart';
import '../../../../plants/application/plants_providers.dart';
import '../../../../plants/presentation/garden_plant_add_screen.dart';
import '../../../../plants/presentation/plant_display.dart';
import '../../../../plants/presentation/widgets/plant_select_row.dart';

/// Step 2 — subjects: multi-select plants + areas-as-subject, with inline
/// "add from catalog" plus explicit "+ add plant / + add area" actions (so an
/// empty garden is never a dead end). A plant's area is context, not a co-equal
/// subject; pick an area explicitly only for whole-area tasks.
class SubjectStepBody extends ConsumerStatefulWidget {
  const SubjectStepBody({
    super.key,
    required this.taskTypeId,
    required this.plantIds,
    required this.areaIds,
    required this.onTogglePlant,
    required this.onToggleArea,
  });

  /// Type chosen in step 1; drives the soft lift of relevant plants (T3).
  final String? taskTypeId;
  final Set<String> plantIds;
  final Set<String> areaIds;
  final void Function(String id, bool selected) onTogglePlant;
  final void Function(String id, bool selected) onToggleArea;

  @override
  ConsumerState<SubjectStepBody> createState() => _SubjectStepBodyState();
}

class _SubjectStepBodyState extends ConsumerState<SubjectStepBody> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'all';
  bool _searchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _addFromCatalog(String plantId) async {
    final id = await ref
        .read(userPlantsRepositoryProvider)
        .create(userId: ref.read(authServiceProvider).userId, plantId: plantId);
    widget.onTogglePlant(id, true);
  }

  /// Opens "add plant" (species + locations) and auto-selects what it creates.
  Future<void> _addPlant() async {
    final ids = await context.pushNamed<List<String>>(
      'plant-add',
      extra: const PlantAddArgs(subjectMode: true),
    );
    if (ids != null) {
      for (final id in ids) {
        widget.onTogglePlant(id, true);
      }
    }
  }

  /// Opens "add area" and auto-selects the new whole-area subject.
  Future<void> _addArea() async {
    final id = await context.pushNamed<String>('area-new');
    if (id != null) widget.onToggleArea(id, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final normQuery = _query.trim().toLowerCase();

    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};
    final userPlants =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final catalogList = ref.watch(plantsListProvider).asData?.value ?? const [];

    bool inCategory(String? plantId) {
      if (_category == 'all') return true;
      final cat = plantId != null ? catalog[plantId]?.category : null;
      return cat != null && coarsePlantCategory(cat) == _category;
    }

    // T3: plant categories the chosen task type applies to (see
    // isCategoryRelevant for the empty/unknown rules).
    final relevantCategories =
        ref.watch(taskTypeCategoriesProvider).asData?.value[widget.taskTypeId] ??
        const <String>{};
    bool isRelevant(String? plantId) => isCategoryRelevant(
      relevantCategories,
      plantId != null ? catalog[plantId]?.category : null,
    );

    final plants = sortedByLabel(
      userPlants.values
          .where((p) => inCategory(p.plantId))
          .where(
            (p) =>
                normQuery.isEmpty ||
                userPlantLabel(p, catalog).toLowerCase().contains(normQuery),
          ),
      (p) => userPlantLabel(p, catalog),
    );
    // Stable partition: relevant plants first, the rest under a muted divider.
    final plantsRelevant = plants.where((p) => isRelevant(p.plantId)).toList();
    final plantsOther = plants.where((p) => !isRelevant(p.plantId)).toList();
    final softSplit = plantsRelevant.isNotEmpty && plantsOther.isNotEmpty;
    final areaList = areas.values.toList();
    final ownedPlantIds = {
      for (final p in userPlants.values)
        if (p.plantId != null) p.plantId,
    };
    final catalogMatchesSorted = normQuery.isEmpty
        ? <Plant>[]
        : sortedByLabel(
            catalogList.where(
              (p) =>
                  !ownedPlantIds.contains(p.id) &&
                  inCategory(p.id) &&
                  plantMatchesQuery(p, normQuery),
            ),
            (p) => catalogLabel(p.labels),
          );
    // Relevant species first (T3), alphabetical within each group.
    final catalogMatches = [
      ...catalogMatchesSorted.where((p) => isRelevant(p.id)),
      ...catalogMatchesSorted.where((p) => !isRelevant(p.id)),
    ];

    // Areas of the selected plants — shown as context, not a co-equal subject.
    final selectedAreaNames = <String>{
      for (final id in widget.plantIds) ?areas[userPlants[id]?.areaId]?.name,
    };

    String? areaSubtitle(UserPlant p) =>
        p.areaId != null && areas[p.areaId] != null
        ? '🪴 ${areas[p.areaId]!.name}'
        : null;

    Widget plantRow(UserPlant p) => PlantSelectRow(
      icon: userPlantIcon(p, catalog),
      title: userPlantLabel(p, catalog),
      subtitle: areaSubtitle(p),
      selected: widget.plantIds.contains(p.id),
      onTap: () =>
          widget.onTogglePlant(p.id, !widget.plantIds.contains(p.id)),
    );

    // Only offer category chips the user actually has plants in — an empty
    // category would just return nothing.
    final presentCategories = <String>{
      for (final p in userPlants.values)
        if (p.plantId != null && catalog[p.plantId] != null)
          coarsePlantCategory(catalog[p.plantId]!.category),
    };
    final categoryChips = presentCategories.isEmpty
        ? const <String>[]
        : [
            'all',
            for (final c in kPlantCategories)
              if (c != 'all' && presentCategories.contains(c)) c,
          ];

    final selectedChips = <({String label, VoidCallback onRemove})>[
      for (final id in widget.plantIds)
        if (userPlants[id] case final p?)
          (
            label: userPlantLabel(p, catalog),
            onRemove: () => widget.onTogglePlant(id, false),
          ),
      for (final id in widget.areaIds)
        if (areas[id] case final a?)
          (label: a.name, onRemove: () => widget.onToggleArea(id, false)),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
            children: [
              if (categoryChips.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      for (final c in categoryChips)
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
              Row(
                children: [
                  Expanded(
                    child: SectionLabel(
                      t.entry.subject_plants,
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _searchExpanded ? Icons.search_off : Icons.search,
                    ),
                    color: theme.colorScheme.primary,
                    onPressed: _toggleSearch,
                  ),
                ],
              ),
              if (_searchExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: t.entry.subject_search_hint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              for (final p in plantsRelevant) plantRow(p),
              if (softSplit)
                SectionLabel(
                  t.entry.subject_less_likely,
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                ),
              for (final p in plantsOther) plantRow(p),
              if (selectedAreaNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                  child: Text(
                    '🪴 ${t.entry.subject_areas_context} '
                    '${selectedAreaNames.join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              _AddAction(label: t.entry.subject_add_plant, onTap: _addPlant),
              if (catalogMatches.isNotEmpty) ...[
                SectionLabel(
                  t.entry.subject_from_catalog,
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                ),
                for (final p in catalogMatches)
                  PlantSelectRow(
                    icon: p.icon ?? '🌿',
                    title: catalogLabel(p.labels),
                    subtitle: plantCategoryLabel(
                      coarsePlantCategory(p.category),
                      t,
                    ),
                    selected: false,
                    onTap: () => _addFromCatalog(p.id),
                  ),
              ],
              const SizedBox(height: 8),
              SectionLabel(
                t.entry.subject_area_section,
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              ),
              if (areaList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final a in areaList)
                        FilterChip(
                          avatar: Text(
                            areaTypeIcon(a.type),
                            style: const TextStyle(fontSize: 14),
                          ),
                          label: Text(a.name),
                          selected: widget.areaIds.contains(a.id),
                          onSelected: (sel) => widget.onToggleArea(a.id, sel),
                        ),
                    ],
                  ),
                ),
              _AddAction(label: t.entry.subject_add_area, onTap: _addArea),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  t.entry.subject_area_note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (selectedChips.isNotEmpty) _SelectedBar(chips: selectedChips),
      ],
    );
  }
}

/// Summary above the shared Continue button — a counter plus the chosen
/// subjects as removable chips, mirroring the plant-add footer.
class _SelectedBar extends StatelessWidget {
  const _SelectedBar({required this.chips});

  final List<({String label, VoidCallback onRemove})> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${chips.length}',
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
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => RemovableChip(
                  label: chips[i].label,
                  onRemove: chips[i].onRemove,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAction extends StatelessWidget {
  const _AddAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
