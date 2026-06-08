import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/swipe_action_background.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/plants_providers.dart';
import '../../data/user_plants_repository.dart';
import '../plant_display.dart';
import 'area_pick_sheet.dart';

/// A plant list row shared by the garden list and an area detail. Swipe right =
/// move (area-pick sheet), swipe left = remove (confirm + soft delete). Tap
/// opens the plant detail.
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

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final ok = await showConfirmDialog(
      context,
      title: t.plant_edit.delete,
      body: t.plant_edit.delete_note,
      confirmLabel: t.plant_edit.delete,
      cancelLabel: t.tasks_list.delete_cancel,
      destructive: true,
    );
    if (ok) {
      await ref.read(userPlantsRepositoryProvider).softDelete(plant.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(plant.id),
      background: SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: theme.colorScheme.primaryContainer,
        foreground: theme.colorScheme.onPrimaryContainer,
        icon: Icons.swap_horiz,
        label: t.areas.swipe_move,
      ),
      secondaryBackground: SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.errorContainer,
        foreground: theme.colorScheme.onErrorContainer,
        icon: Icons.delete_outline,
        label: t.areas.swipe_remove,
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          await _move(context, ref);
        } else {
          await _remove(context, ref);
        }
        // Always false: the watching stream drops the row (move relocates it,
        // remove soft-deletes it), which avoids the "dismissed widget still in
        // tree" assert that returning true would risk on the next rebuild.
        return false;
      },
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
