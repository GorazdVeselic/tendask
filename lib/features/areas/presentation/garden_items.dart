import '../../../core/area_type.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';

/// One row of the flat garden list. The hierarchy reads top-down: a section
/// label, then an area header, then a card holding that area's plants.
sealed class GardenItem {
  const GardenItem();
}

/// Section label for plants that belong to no area — always first.
class GardenUnassignedSection extends GardenItem {
  const GardenUnassignedSection();
}

class GardenTypeSection extends GardenItem {
  const GardenTypeSection(this.type);
  final AreaType type;
}

class GardenAreaItem extends GardenItem {
  const GardenAreaItem({
    required this.area,
    required this.lastTask,
    required this.plantCount,
  });

  final Area area;
  final Task? lastTask;
  final int plantCount;
}

class GardenPlantsItem extends GardenItem {
  const GardenPlantsItem(this.plants);
  final List<UserPlant> plants;
}

/// Splits plants into per-area buckets and the ones with no area yet.
({Map<String, List<UserPlant>> byArea, List<UserPlant> unassigned})
groupPlantsByArea(Iterable<UserPlant> plants) {
  final byArea = <String, List<UserPlant>>{};
  final unassigned = <UserPlant>[];
  for (final p in plants) {
    final areaId = p.areaId;
    if (areaId != null) {
      (byArea[areaId] ??= []).add(p);
    } else {
      unassigned.add(p);
    }
  }
  return (byArea: byArea, unassigned: unassigned);
}

/// Flattens the garden into display order: unassigned plants first, then the
/// areas grouped by type in [AreaType] declaration order, each followed by its
/// plants. Empty when there is nothing to show (first run).
List<GardenItem> buildGardenItems({
  required List<Area> areas,
  required Map<String, List<UserPlant>> plantsByArea,
  required List<UserPlant> unassigned,
  required Map<String, Task> latestTaskPerArea,
}) {
  final items = <GardenItem>[];
  if (unassigned.isNotEmpty) {
    items.add(const GardenUnassignedSection());
    items.add(GardenPlantsItem(unassigned));
  }
  for (final type in AreaType.values) {
    final inType = areas.where((a) => a.type == type).toList();
    if (inType.isEmpty) continue;
    items.add(GardenTypeSection(type));
    for (final area in inType) {
      final plants = plantsByArea[area.id] ?? const <UserPlant>[];
      items.add(
        GardenAreaItem(
          area: area,
          lastTask: latestTaskPerArea[area.id],
          plantCount: plants.length,
        ),
      );
      if (plants.isNotEmpty) items.add(GardenPlantsItem(plants));
    }
  }
  return items;
}

/// Subtitle under an area name: its last task, else how many plants it holds.
/// Never the area type — the section label above already names it for the group.
String areaSubtitle(
  Translations t, {
  required Task? lastTask,
  required Map<String, TaskType> catalog,
  required int plantCount,
}) {
  if (lastTask == null) {
    return plantCount == 0 ? t.areas.no_plants : t.areas.plant_count(n: plantCount);
  }
  final type = catalog[lastTask.taskTypeId];
  final label = type != null ? catalogLabel(type.labels) : lastTask.taskTypeId;
  return '${t.areas.last_prefix} $label · ${formatDmy(lastTask.date.toLocal())}';
}
