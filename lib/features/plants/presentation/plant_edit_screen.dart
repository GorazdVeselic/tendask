import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/plants_providers.dart';
import 'plant_picker_screen.dart';

/// Add or edit a personal plant. Add mode: pick species + alias + one or more
/// areas (one instance per area). Edit mode: alias + the instance's area + delete.
class PlantEditScreen extends ConsumerStatefulWidget {
  const PlantEditScreen({super.key, this.userPlantId});

  final String? userPlantId;

  @override
  ConsumerState<PlantEditScreen> createState() => _PlantEditScreenState();
}

class _PlantEditScreenState extends ConsumerState<PlantEditScreen> {
  String? _plantId;
  String? _customName;
  final _aliasController = TextEditingController();
  final Set<String> _areaIds = {}; // add mode: one instance per area
  String? _editAreaId; // edit mode: the single instance's area
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.userPlantId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _isLoading = true;
      Future.microtask(_load);
    }
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plant =
        await ref.read(userPlantsRepositoryProvider).byId(widget.userPlantId!);
    if (!mounted) return;
    if (plant != null) {
      setState(() {
        _plantId = plant.plantId;
        _customName = plant.customName;
        _aliasController.text = plant.personalAlias ?? '';
        _editAreaId = plant.areaId;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickSpecies() async {
    final pick = await context.pushNamed<PlantPick>('plant-picker');
    if (pick == null || !mounted) return;
    setState(() {
      _plantId = pick.plantId;
      _customName = pick.customName;
    });
  }

  Future<void> _save() async {
    final t = context.t;
    if (_plantId == null && _customName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t.plant_edit.err_species),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(userPlantsRepositoryProvider);
      final alias = _aliasController.text.trim();
      final aliasOrNull = alias.isEmpty ? null : alias;
      // Created instance ids — returned to callers that auto-select the new
      // plant (e.g. the entry subject step). Null on edit.
      List<String>? created;
      if (_isEdit) {
        await repo.update(
          id: widget.userPlantId!,
          areaId: _editAreaId,
          personalAlias: aliasOrNull,
        );
      } else if (_areaIds.isEmpty) {
        created = [
          await repo.create(
            // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
            userId: 'local',
            plantId: _plantId,
            customName: _customName,
            personalAlias: aliasOrNull,
          ),
        ];
      } else {
        created = [
          for (final areaId in _areaIds)
            await repo.create(
              userId: 'local',
              areaId: areaId,
              plantId: _plantId,
              customName: _customName,
              personalAlias: aliasOrNull,
            ),
        ];
      }
      if (mounted) context.pop(created);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.plant_edit.delete,
      body: t.plant_edit.delete_note,
      confirmLabel: t.plant_edit.delete,
      cancelLabel: t.tasks_list.delete_cancel,
    );
    if (!confirmed) return;
    await ref.read(userPlantsRepositoryProvider).softDelete(widget.userPlantId!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasListProvider).asData?.value ?? const [];

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(t.plant_edit.title_edit)),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: context.pop),
        title: Text(_isEdit ? t.plant_edit.title_edit : t.plant_edit.title_new),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                _Label(t.plant_edit.species),
                _SpeciesField(
                  plantId: _plantId,
                  customName: _customName,
                  catalog: catalog,
                  t: t,
                  theme: theme,
                  onPick: _pickSpecies,
                ),
                const SizedBox(height: 16),
                _Label(t.plant_edit.alias),
                TextField(
                  controller: _aliasController,
                  decoration: InputDecoration(
                    hintText: t.plant_edit.alias_hint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t.plant_edit.alias_note,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
                const SizedBox(height: 16),
                _Label('${t.plant_edit.locations} · ${t.plant_edit.locations_hint}'),
                _LocationField(
                  areas: areas,
                  isEdit: _isEdit,
                  selectedAdd: _areaIds,
                  selectedEdit: _editAreaId,
                  t: t,
                  onToggleAdd: (id, sel) => setState(
                      () => sel ? _areaIds.add(id) : _areaIds.remove(id)),
                  onSelectEdit: (id) => setState(() => _editAreaId =
                      _editAreaId == id ? null : id),
                  onNewArea: () => context.pushNamed('area-new'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t.plant_edit.locations_note,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: _delete,
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      label: Text(t.plant_edit.delete,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SaveBar(onSave: _save, isSaving: _isSaving, label: t.plant_edit.save),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SpeciesField extends StatelessWidget {
  const _SpeciesField({
    required this.plantId,
    required this.customName,
    required this.catalog,
    required this.t,
    required this.theme,
    required this.onPick,
  });

  final String? plantId;
  final String? customName;
  final Map<String, Plant> catalog;
  final Translations t;
  final ThemeData theme;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final plant = plantId != null ? catalog[plantId] : null;
    final hasSpecies = plant != null || customName != null;
    final icon = plant?.icon ?? (customName != null ? '🌿' : null);
    final label = plant != null
        ? catalogLabel(plant.labels)
        : (customName ?? t.plant_edit.species_choose);

    return Card(
      child: ListTile(
        leading: icon != null
            ? Text(icon, style: const TextStyle(fontSize: 22))
            : Icon(Icons.eco_outlined, color: theme.colorScheme.onSurfaceVariant),
        title: Text(label),
        subtitle: plant?.scientificName != null
            ? Text(plant!.scientificName!)
            : null,
        trailing: Text(
          hasSpecies ? t.plant_edit.species_change : t.plant_edit.species_choose,
          style: TextStyle(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        onTap: onPick,
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.areas,
    required this.isEdit,
    required this.selectedAdd,
    required this.selectedEdit,
    required this.t,
    required this.onToggleAdd,
    required this.onSelectEdit,
    required this.onNewArea,
  });

  final List<Area> areas;
  final bool isEdit;
  final Set<String> selectedAdd;
  final String? selectedEdit;
  final Translations t;
  final void Function(String id, bool selected) onToggleAdd;
  final ValueChanged<String> onSelectEdit;
  final VoidCallback onNewArea;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final area in areas)
            CheckboxListTile(
              value: isEdit
                  ? selectedEdit == area.id
                  : selectedAdd.contains(area.id),
              onChanged: (sel) => isEdit
                  ? onSelectEdit(area.id)
                  : onToggleAdd(area.id, sel ?? false),
              title: Text(area.name),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onNewArea,
              icon: const Icon(Icons.add, size: 18),
              label: Text(t.plant_edit.new_area),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
    );
  }
}
