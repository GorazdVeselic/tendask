import 'dart:convert';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';

/// Display name for a user plant: private alias wins, then custom name, then
/// the catalog label. Never throws.
String userPlantLabel(UserPlant up, Map<String, Plant> catalog) {
  if (up.personalAlias != null && up.personalAlias!.isNotEmpty) {
    return up.personalAlias!;
  }
  if (up.customName != null && up.customName!.isNotEmpty) {
    return up.customName!;
  }
  final plant = up.plantId != null ? catalog[up.plantId] : null;
  return plant != null ? catalogLabel(plant.labels) : '🌿';
}

/// Emoji for a user plant — catalog icon, or a leaf for custom entries.
String userPlantIcon(UserPlant up, Map<String, Plant> catalog) {
  final plant = up.plantId != null ? catalog[up.plantId] : null;
  return plant?.icon ?? '🌿';
}

/// True if [normQuery] (already lowercased) matches the plant's names in any
/// language or its scientific name. Synonyms are out of scope until the
/// `plant_synonym` table is seeded (larger catalog tier).
bool plantMatchesQuery(Plant p, String normQuery) {
  if (normQuery.isEmpty) return true;
  final haystack = <String>[];
  try {
    final m = jsonDecode(p.labels) as Map<String, dynamic>;
    for (final v in m.values) {
      if (v is String) haystack.add(v);
    }
  } catch (_) {
    haystack.add(p.labels);
  }
  if (p.scientificName != null) haystack.add(p.scientificName!);
  return haystack.any((s) => s.toLowerCase().contains(normQuery));
}
