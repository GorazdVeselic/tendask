import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/area_type.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/data/plant_spec.dart';
import '../../plants/presentation/plant_picker_screen.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';

class AreaFormScreen extends ConsumerStatefulWidget {
  const AreaFormScreen({super.key, this.areaId});

  /// Null = create mode; non-null = edit mode.
  final String? areaId;

  @override
  ConsumerState<AreaFormScreen> createState() => _AreaFormScreenState();
}

class _AreaFormScreenState extends ConsumerState<AreaFormScreen> {
  final _nameController = TextEditingController();
  AreaType _type = AreaType.other;
  final List<PlantSpec> _plants = [];
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.areaId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _isLoading = true;
      Future.microtask(_loadArea);
    }
  }

  Future<void> _loadArea() async {
    final area = await ref.read(areasRepositoryProvider).byId(widget.areaId!);
    final plants =
        await ref.read(userPlantsRepositoryProvider).byArea(widget.areaId!);
    if (!mounted) return;
    if (area != null) {
      setState(() {
        _nameController.text = area.name;
        _type = area.type;
        _plants
          ..clear()
          ..addAll(plants.map((p) => PlantSpec(
                userPlantId: p.id,
                plantId: p.plantId,
                customName: p.customName,
                personalAlias: p.personalAlias,
              )));
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addPlant() async {
    final pick = await context.pushNamed<PlantPick>('plant-picker');
    if (pick == null || !mounted) return;
    setState(() => _plants.add(PlantSpec(
          plantId: pick.plantId,
          customName: pick.customName,
        )));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _save() async {
    final t = context.t;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(t.areas.err_name);
      return;
    }

    setState(() => _isSaving = true);
    try {
      // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
      const userId = 'local';
      final repo = ref.read(areasRepositoryProvider);
      final String areaId;
      if (_isEdit) {
        await repo.update(id: widget.areaId!, name: name, type: _type);
        areaId = widget.areaId!;
      } else {
        areaId = await repo.create(userId: userId, name: name, type: _type);
      }
      await ref.read(userPlantsRepositoryProvider).syncForArea(
            userId: userId,
            areaId: areaId,
            specs: _plants,
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: context.pop,
        ),
        title: Text(_isEdit ? t.areas.form_title_edit : t.areas.form_title_new),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    children: [
                      _FieldLabel(t.areas.form_name),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: t.areas.form_name_hint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(t.areas.form_type),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final type in AreaType.values)
                            ChoiceChip(
                              label: Text(areaTypeLabel(type, t)),
                              selected: type == _type,
                              onSelected: (_) => setState(() => _type = type),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(t.areas.form_plants),
                      _PlantsSection(
                        plants: _plants,
                        catalog: catalog,
                        t: t,
                        theme: theme,
                        onAdd: _addPlant,
                        onRemove: (i) => setState(() => _plants.removeAt(i)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          t.areas.form_plants_note,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SaveBar(
                  onSave: _save,
                  isSaving: _isSaving,
                  label: t.areas.form_save,
                ),
              ],
            ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _PlantsSection extends StatelessWidget {
  const _PlantsSection({
    required this.plants,
    required this.catalog,
    required this.t,
    required this.theme,
    required this.onAdd,
    required this.onRemove,
  });

  final List<PlantSpec> plants;
  final Map<String, Plant> catalog;
  final Translations t;
  final ThemeData theme;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  String _label(PlantSpec spec) {
    if (spec.customName != null) return spec.customName!;
    final plant = spec.plantId != null ? catalog[spec.plantId] : null;
    return plant != null ? catalogLabel(plant.labels) : '🌿';
  }

  String _icon(PlantSpec spec) {
    final plant = spec.plantId != null ? catalog[spec.plantId] : null;
    return plant?.icon ?? '🌿';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          if (plants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.areas.plants_empty,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            for (var i = 0; i < plants.length; i++)
              ListTile(
                leading:
                    Text(_icon(plants[i]), style: const TextStyle(fontSize: 20)),
                title:
                    Text(_label(plants[i]), style: theme.textTheme.bodyMedium),
                trailing: IconButton(
                  icon: Icon(Icons.close,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                  tooltip: t.areas.plant_remove,
                  onPressed: () => onRemove(i),
                ),
                dense: true,
              ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          InkWell(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            onTap: onAdd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(t.areas.form_plants_add,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

