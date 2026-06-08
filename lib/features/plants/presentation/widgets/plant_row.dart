import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/swipe_actions.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/plants_providers.dart';
import '../../data/user_plants_repository.dart';
import '../plant_display.dart';
import 'area_pick_sheet.dart';

/// A plant list row shared by the garden list and an area detail. Swipe reveals
/// move (area-pick sheet) and delete (confirm + soft delete); tap opens detail.
class PlantRow extends ConsumerWidget {
  const PlantRow({required this.plant, required this.catalog, super.key});

  final UserPlant plant;
  final Map<String, Plant> catalog;

  Future<void> _move(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final pick = await showAreaPickSheet(
      context,
      title: t.area_pick.move_title(name: userPlantLabel(plant, catalog)),
      currentAreaId: plant.areaId,
    );
    if (pick == null || !context.mounted) return;
    // Preserve the alias — moveToArea() rewrites it.
    final res = await ref
        .read(userPlantsRepositoryProvider)
        .moveToArea(
          id: plant.id,
          areaId: pick.areaId,
          personalAlias: plant.personalAlias,
        );
    if (res == PlantMoveResult.duplicate && context.mounted) {
      showTopToast(context, t.area_pick.duplicate, error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    return SwipeRow(
      itemKey: plant.id,
      actions: [
        moveSwipe(context, () => unawaited(_move(context, ref))),
        deleteSwipe(
          context,
          title: t.plant_edit.delete,
          body: t.plant_edit.delete_note,
          onConfirmed: () =>
              ref.read(userPlantsRepositoryProvider).softDelete(plant.id),
        ),
      ],
      child: ListTile(
        leading: Text(
          userPlantIcon(plant, catalog),
          style: const TextStyle(fontSize: 20),
        ),
        title: Text(userPlantLabel(plant, catalog)),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () =>
            context.pushNamed('plant-detail', pathParameters: {'id': plant.id}),
      ),
    );
  }
}
