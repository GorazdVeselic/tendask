import '../../../core/area_type.dart';
import '../../../i18n/translations.g.dart';
import '../../../core/glyphs.dart';

/// Emoji avatar for an area type (presentation mapping, not domain logic).
String areaTypeIcon(AreaType type) => switch (type) {
  AreaType.garden => kGlyphAreaGarden,
  AreaType.lawn => kGlyphAreaLawn,
  AreaType.hedge => kGlyphAreaHedge,
  AreaType.bed => kGlyphAreaBed,
  AreaType.tree => kGlyphAreaTree,
  AreaType.ornamental => kGlyphAreaOrnamental,
  AreaType.other => kGlyphAreaOther,
};

/// Localized label for an area type.
String areaTypeLabel(AreaType type, Translations t) => switch (type) {
  AreaType.garden => t.areas.type_garden,
  AreaType.lawn => t.areas.type_lawn,
  AreaType.hedge => t.areas.type_hedge,
  AreaType.bed => t.areas.type_bed,
  AreaType.tree => t.areas.type_tree,
  AreaType.ornamental => t.areas.type_ornamental,
  AreaType.other => t.areas.type_other,
};
