import '../../../core/database/app_database.dart';
import '../../plants/presentation/plant_display.dart';

/// Human label for a single task subject: plant name (alias/custom/catalog) when
/// it is a plant, else the area name. Empty when nothing resolves.
String subjectLabel(
  TaskSubject subject, {
  required Map<String, Area> areas,
  required Map<String, UserPlant> userPlants,
  required Map<String, Plant> plants,
}) {
  if (subject.userPlantId != null) {
    final up = userPlants[subject.userPlantId];
    return up != null ? userPlantLabel(up, plants) : '';
  }
  if (subject.areaId != null) {
    return areas[subject.areaId]?.name ?? '';
  }
  return '';
}

/// Joined subject labels per task id (e.g. "Paradižnik, Solata, Trata zadaj"),
/// for rendering the "for what" subtitle in task lists. Tasks with no resolvable
/// subject are omitted.
Map<String, String> subjectLabelsByTask(
  List<TaskSubject> subjects, {
  required Map<String, Area> areas,
  required Map<String, UserPlant> userPlants,
  required Map<String, Plant> plants,
}) {
  final byTask = <String, List<String>>{};
  for (final s in subjects) {
    final label = subjectLabel(s,
        areas: areas, userPlants: userPlants, plants: plants);
    if (label.isEmpty) continue;
    (byTask[s.taskId] ??= <String>[]).add(label);
  }
  return {for (final e in byTask.entries) e.key: e.value.join(', ')};
}
