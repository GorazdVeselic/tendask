import 'area_type.dart';

/// Plant categories that fit an area of [type] — the T4 soft lift when adding
/// plants to a specific area (you don't plant a tree in a raised bed).
///
/// An empty set means "no preference": `garden` and `other` are catch-all
/// areas, and a null [type] (no target area) lifts nothing, so the picker shows
/// every plant without a divider. Pair with `isCategoryRelevant`, which keeps
/// unknown/custom categories above the "less likely" line. Categories are the
/// fine seed buckets stored on `plant.category`.
Set<String> relevantPlantCategories(AreaType? type) => switch (type) {
  AreaType.lawn => const {'lawn'},
  AreaType.hedge => const {'hedge', 'shrub', 'conifer'},
  AreaType.bed => const {
    'vegetable',
    'herbs',
    'berries',
    'perennial',
    'bulb',
    'climber',
  },
  AreaType.tree => const {'fruit_tree', 'citrus', 'conifer'},
  AreaType.ornamental => const {
    'perennial',
    'shrub',
    'bulb',
    'climber',
    'conifer',
    'hedge',
  },
  AreaType.garden || AreaType.other || null => const {},
};
