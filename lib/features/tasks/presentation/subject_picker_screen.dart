import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../areas/presentation/area_type_display.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/presentation/plant_display.dart';
import '../data/tasks_repository.dart';

/// Multi-select picker for task subjects: existing plants + areas, plus inline
/// "add from catalog" (creates a personal plant). Returns the chosen subjects
/// via `context.pop(List<TaskSubjectSpec>)`.
class SubjectPickerScreen extends ConsumerStatefulWidget {
  const SubjectPickerScreen({super.key, this.initial = const []});

  final List<TaskSubjectSpec> initial;

  @override
  ConsumerState<SubjectPickerScreen> createState() =>
      _SubjectPickerScreenState();
}

class _SubjectPickerScreenState extends ConsumerState<SubjectPickerScreen> {
  final _searchController = TextEditingController();
  late final Set<String> _plantIds;
  late final Set<String> _areaIds;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _plantIds = {
      for (final s in widget.initial)
        if (s.userPlantId != null) s.userPlantId!,
    };
    _areaIds = {
      for (final s in widget.initial)
        if (s.areaId != null) s.areaId!,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _count => _plantIds.length + _areaIds.length;

  Future<void> _addFromCatalog(String plantId) async {
    final id = await ref
        .read(userPlantsRepositoryProvider)
        // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
        .create(userId: 'local', plantId: plantId);
    if (mounted) setState(() => _plantIds.add(id));
  }

  void _confirm() {
    final result = <TaskSubjectSpec>[
      for (final id in _plantIds) TaskSubjectSpec.plant(id),
      for (final id in _areaIds) TaskSubjectSpec.area(id),
    ];
    context.pop(result);
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
    final areaList = areas.values
        .where((a) =>
            normQuery.isEmpty || a.name.toLowerCase().contains(normQuery))
        .toList();
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: context.pop),
        title: Text(t.subject_picker.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.subject_picker.search_hint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              children: [
                if (plants.isNotEmpty) ...[
                  _SectionLabel(t.subject_picker.section_plants, theme: theme),
                  for (final p in plants)
                    CheckboxListTile(
                      value: _plantIds.contains(p.id),
                      onChanged: (sel) => setState(() =>
                          sel == true ? _plantIds.add(p.id) : _plantIds.remove(p.id)),
                      secondary: Text(userPlantIcon(p, catalog),
                          style: const TextStyle(fontSize: 20)),
                      title: Text(userPlantLabel(p, catalog)),
                      subtitle: p.areaId != null && areas[p.areaId] != null
                          ? Text('🪴 ${areas[p.areaId]!.name}')
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                ],
                if (areaList.isNotEmpty) ...[
                  _SectionLabel(t.subject_picker.section_areas, theme: theme),
                  for (final a in areaList)
                    CheckboxListTile(
                      value: _areaIds.contains(a.id),
                      onChanged: (sel) => setState(() =>
                          sel == true ? _areaIds.add(a.id) : _areaIds.remove(a.id)),
                      secondary: Text(areaTypeIcon(a.type),
                          style: const TextStyle(fontSize: 20)),
                      title: Text(a.name),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                ],
                if (catalogMatches.isNotEmpty) ...[
                  _SectionLabel(t.subject_picker.from_catalog, theme: theme),
                  for (final p in catalogMatches)
                    ListTile(
                      leading: Text(p.icon ?? '🌿',
                          style: const TextStyle(fontSize: 20)),
                      title: Text(catalogLabel(p.labels)),
                      subtitle: p.scientificName != null
                          ? Text(p.scientificName!)
                          : null,
                      trailing: Icon(Icons.add, color: theme.colorScheme.primary),
                      dense: true,
                      onTap: () => _addFromCatalog(p.id),
                    ),
                ],
                if (plants.isEmpty && areaList.isEmpty && catalogMatches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      t.subject_picker.empty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _count == 0 ? null : _confirm,
                  child: Text('${t.subject_picker.confirm} ($_count)'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.theme});
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
