import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import 'community_models.dart';

/// The catalog species behind a garden plant, or null when there is none to
/// compare against: a private custom entry never joins the aggregate (it would
/// be a group of one), and neither does a plant with no catalog link.
String? catalogPlantOf(UserPlant userPlant) {
  final plantId = userPlant.plantId;
  if (userPlant.isCustom || plantId == null) return null;
  return plantId;
}

/// The comparison cohort a task belongs to (§7.4), mirroring what `agg_event`
/// records on the server: a subject on a catalog species compares within that
/// species, while an area, a private plant or no subject at all is site work.
///
/// A task can carry several subjects; the aggregate counts it in each of their
/// cohorts, but a screen has to open in exactly one — the first catalog species,
/// in the order the subjects were added.
String cohortOfSubjects(
  Iterable<TaskSubject> subjects,
  Map<String, UserPlant> userPlants,
) {
  for (final subject in subjects) {
    if (subject.deleted) continue;
    final userPlant = userPlants[subject.userPlantId];
    if (userPlant == null) continue;
    if (catalogPlantOf(userPlant) case final plantId?) return plantId;
  }
  return kCommunityCohortSite;
}

/// The one feed row worth putting on Home: the busiest one about a species this
/// garden actually grows, else the busiest row overall. The feed is already
/// ranked, so "first match" means "busiest match".
///
/// Site rows never win the preference — a lawn cohort matches every garden, so
/// treating it as personal would hand the slot to whatever happens to lead the
/// feed and call it relevant. They still qualify as the fallback.
CommunityFeedItem? pickHomeHint(
  List<CommunityFeedItem> items,
  Set<String> myPlantIds,
) {
  for (final item in items) {
    if (item.cohort == kCommunityCohortSite) continue;
    if (myPlantIds.contains(item.cohort)) return item;
  }
  return items.isEmpty ? null : items.first;
}
