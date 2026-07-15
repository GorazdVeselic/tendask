import '../../../../../core/database/app_database.dart';

/// Ordering behind the task-type grid, kept out of the widget so the ranking
/// and the "keep the selection visible" rule can be tested.

/// The catalog ordered by per-user frequency (most used first); ties keep the
/// original seed order so the grid never reshuffles arbitrarily.
List<TaskType> sortTaskTypesByUsage(
  Map<String, TaskType> catalog,
  Map<String, int> usage,
) {
  final list = catalog.values.toList();
  final seedOrder = {for (var i = 0; i < list.length; i++) list[i].id: i};
  list.sort((a, b) {
    final byUse = (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0);
    return byUse != 0 ? byUse : seedOrder[a.id]!.compareTo(seedOrder[b.id]!);
  });
  return list;
}

/// Keeps [selected] on screen even when it falls outside the collapsed window
/// (e.g. returning to this step from review), by appending it to [visible].
List<TaskType> ensureSelectedVisible(
  List<TaskType> visible,
  List<TaskType> all,
  String? selected,
) {
  if (selected == null || visible.any((t) => t.id == selected)) return visible;
  final extra = all.where((t) => t.id == selected);
  return extra.isEmpty ? visible : [...visible, extra.first];
}
