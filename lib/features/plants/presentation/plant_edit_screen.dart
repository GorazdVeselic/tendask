import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/plants_providers.dart';
import '../data/user_plants_repository.dart';
import 'widgets/area_pick_sheet.dart';

/// Edit a personal plant instance: alias + its area (single — move) + delete.
/// Species is identity (set when the plant was added) and is shown read-only;
/// adding plants is the separate instant-add screen.
class PlantEditScreen extends ConsumerStatefulWidget {
  const PlantEditScreen({required this.userPlantId, super.key});

  final String userPlantId;

  @override
  ConsumerState<PlantEditScreen> createState() => _PlantEditScreenState();
}

class _PlantEditScreenState extends ConsumerState<PlantEditScreen> {
  String? _plantId;
  String? _customName;
  final _aliasController = TextEditingController();
  String? _areaId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plant =
        await ref.read(userPlantsRepositoryProvider).byId(widget.userPlantId);
    if (!mounted) return;
    if (plant != null) {
      setState(() {
        _plantId = plant.plantId;
        _customName = plant.customName;
        _aliasController.text = plant.personalAlias ?? '';
        _areaId = plant.areaId;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _changeArea() async {
    final t = context.t;
    final pick = await showAreaPickSheet(
      context,
      title: t.area_pick.choose_title,
      currentAreaId: _areaId,
    );
    if (pick == null || !mounted) return;
    setState(() => _areaId = pick.areaId);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final alias = _aliasController.text.trim();
      final res = await ref.read(userPlantsRepositoryProvider).moveToArea(
            id: widget.userPlantId,
            areaId: _areaId,
            personalAlias: alias.isEmpty ? null : alias,
          );
      if (!mounted) return;
      if (res == PlantMoveResult.duplicate) {
        showTopToast(context, context.t.area_pick.duplicate, error: true);
        return;
      }
      context.pop();
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
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(userPlantsRepositoryProvider).softDelete(widget.userPlantId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(t.plant_edit.title_edit)),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(icon: const Icon(Icons.close), onPressed: context.pop),
        title: Text(t.plant_edit.title_edit),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                FieldLabel(t.plant_edit.species),
                _SpeciesCard(
                  plantId: _plantId,
                  customName: _customName,
                  catalog: catalog,
                ),
                const SizedBox(height: 16),
                FieldLabel(t.plant_edit.alias),
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
                FieldLabel(t.plant_edit.location_label),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.place_outlined,
                        color: theme.colorScheme.onSurfaceVariant),
                    title: Text(
                        _areaId != null ? areas[_areaId]?.name ?? t.area_pick.none : t.area_pick.none),
                    trailing: Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant),
                    onTap: _changeArea,
                  ),
                ),
                const SizedBox(height: 24),
                DestructiveButton(
                  label: t.plant_edit.delete,
                  onPressed: _delete,
                ),
              ],
            ),
          ),
          SaveBar(onSave: _save, isSaving: _isSaving, label: t.plant_edit.save),
        ],
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  const _SpeciesCard({
    required this.plantId,
    required this.customName,
    required this.catalog,
  });

  final String? plantId;
  final String? customName;
  final Map<String, Plant> catalog;

  @override
  Widget build(BuildContext context) {
    final plant = plantId != null ? catalog[plantId] : null;
    final icon = plant?.icon ?? '🌿';
    final label = plant != null ? catalogLabel(plant.labels) : (customName ?? '🌿');

    return Card(
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(label),
        subtitle: plant?.scientificName != null
            ? Text(plant!.scientificName!)
            : null,
      ),
    );
  }
}
