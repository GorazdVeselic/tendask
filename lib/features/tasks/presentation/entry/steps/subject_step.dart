import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/catalog_labels.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/database/catalog_provider.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../../areas/application/areas_providers.dart';
import '../../../../areas/presentation/area_type_display.dart';
import '../../../../plants/application/plants_providers.dart';
import '../../../../plants/presentation/plant_display.dart';

/// Step 2 — subjects: multi-select plants + areas-as-subject, with inline
/// "add from catalog" plus explicit "+ add plant / + add area" actions (so an
/// empty garden is never a dead end). A plant's area is context, not a co-equal
/// subject; pick an area explicitly only for whole-area tasks.
class SubjectStepBody extends ConsumerStatefulWidget {
  const SubjectStepBody({
    super.key,
    required this.plantIds,
    required this.areaIds,
    required this.onTogglePlant,
    required this.onToggleArea,
  });

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addFromCatalog(String plantId) async {
    final id = await ref
        .read(userPlantsRepositoryProvider)
        // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
        .create(userId: 'local', plantId: plantId);
    widget.onTogglePlant(id, true);
  }

  /// Opens "add plant" (species + locations) and auto-selects what it creates.
  Future<void> _addPlant() async {
    final ids = await context.pushNamed<List<String>>('plant-new');
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

    final plants = userPlants.values
        .where((p) =>
            normQuery.isEmpty ||
            userPlantLabel(p, catalog).toLowerCase().contains(normQuery))
        .toList();
    final areaList = areas.values.toList();
    final ownedPlantIds = {
      for (final p in userPlants.values)
        if (p.plantId != null) p.plantId,
    };
    final catalogMatches = normQuery.isEmpty
        ? <Plant>[]
        : catalogList
            .where((p) =>
                !ownedPlantIds.contains(p.id) && plantMatchesQuery(p, normQuery))
            .toList();

    // Areas of the selected plants — shown as context, not a co-equal subject.
    final selectedAreaNames = <String>{
      for (final id in widget.plantIds)
        ?areas[userPlants[id]?.areaId]?.name,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: t.entry.subject_search_hint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            children: [
              _SectionLabel(t.entry.subject_plants),
              for (final p in plants)
                CheckboxListTile(
                  value: widget.plantIds.contains(p.id),
                  onChanged: (sel) => widget.onTogglePlant(p.id, sel == true),
                  secondary: Text(userPlantIcon(p, catalog),
                      style: const TextStyle(fontSize: 20)),
                  title: Text(userPlantLabel(p, catalog)),
                  subtitle: p.areaId != null && areas[p.areaId] != null
                      ? Text('🪴 ${areas[p.areaId]!.name}')
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              if (selectedAreaNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                  child: Text(
                    '🪴 ${t.entry.subject_areas_context} '
                    '${selectedAreaNames.join(', ')}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              _AddAction(label: t.entry.subject_add_plant, onTap: _addPlant),
              if (catalogMatches.isNotEmpty) ...[
                _SectionLabel(t.entry.subject_from_catalog),
                for (final p in catalogMatches)
                  ListTile(
                    leading:
                        Text(p.icon ?? '🌿', style: const TextStyle(fontSize: 20)),
                    title: Text(catalogLabel(p.labels)),
                    subtitle: p.scientificName != null
                        ? Text(p.scientificName!)
                        : null,
                    trailing: Icon(Icons.add, color: theme.colorScheme.primary),
                    dense: true,
                    onTap: () => _addFromCatalog(p.id),
                  ),
              ],
              const SizedBox(height: 8),
              _SectionLabel(
                  '${t.entry.subject_area_section} ${t.entry.subject_area_hint}'),
              if (areaList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final a in areaList)
                        FilterChip(
                          avatar: Text(areaTypeIcon(a.type),
                              style: const TextStyle(fontSize: 14)),
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
                child: Text(t.entry.subject_area_note,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
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
            visualDensity: VisualDensity.compact),
      ),
    );
  }
}
