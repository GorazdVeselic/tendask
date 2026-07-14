/// The vocabulary of the tasks repository boundary: drift-free value types the
/// UI builds and the repository consumes (CLAUDE.md — no Companion in
/// signatures). They live outside `data/` so presentation never has to import it.
library;

/// A subject on the repository boundary: a plant OR an area-as-subject.
class TaskSubjectSpec {
  const TaskSubjectSpec({this.userPlantId, this.areaId})
    : assert(
        userPlantId != null || areaId != null,
        'A subject must reference a plant or an area',
      );
  const TaskSubjectSpec.plant(String userPlantId)
    : this(userPlantId: userPlantId);
  const TaskSubjectSpec.area(String areaId) : this(areaId: areaId);

  final String? userPlantId;
  final String? areaId;
}

/// A reminder on the repository boundary.
class ReminderSpec {
  const ReminderSpec({required this.offsetMinutes, this.time});

  /// Minutes before the task date; 0 = at event time.
  final int offsetMinutes;

  /// "HH:mm" time of day for the notification; null = use the task's own time.
  final String? time;
}
