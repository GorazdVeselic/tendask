import '../../../../core/biodynamic/biodynamic_day.dart';
import '../../../../core/glyphs.dart';

/// Emoji glyph of a biodynamic element (FR-19, decision A5 fallback: emoji,
/// same set as the wireframes). One constant for every surface that shows an
/// element glyph.
String elementEmoji(BiodynamicElement element) => switch (element) {
  BiodynamicElement.fruit => kGlyphFruit,
  BiodynamicElement.root => kGlyphRoot,
  BiodynamicElement.flower => kGlyphFlower,
  BiodynamicElement.leaf => kGlyphLeaf,
};
