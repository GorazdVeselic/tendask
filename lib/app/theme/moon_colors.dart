import 'package:flutter/material.dart';

/// Fixed semantic colours of the four moon calendar elements (FR-19, decision
/// A4): one light + one dark instance shared by all six palettes, so an element
/// keeps its recognisable colour regardless of the chosen palette. Strong tone
/// = icon/label accent, soft tone = calendar cell / chip background. Light
/// values come from the v2 wireframe; dark follow the terracotta pattern
/// (lighter accent, muted dark container). Widgets read them via
/// `Theme.of(context).extension<MoonColors>()`, never hardcoded hex.
class MoonColors extends ThemeExtension<MoonColors> {
  const MoonColors({
    required this.fruit,
    required this.fruitSoft,
    required this.root,
    required this.rootSoft,
    required this.flower,
    required this.flowerSoft,
    required this.leaf,
    required this.leafSoft,
  });

  final Color fruit; // fire — fruit day
  final Color fruitSoft;
  final Color root; // earth — root day
  final Color rootSoft;
  final Color flower; // air — flower day
  final Color flowerSoft;
  final Color leaf; // water — leaf day
  final Color leafSoft;

  @override
  MoonColors copyWith({
    Color? fruit,
    Color? fruitSoft,
    Color? root,
    Color? rootSoft,
    Color? flower,
    Color? flowerSoft,
    Color? leaf,
    Color? leafSoft,
  }) => MoonColors(
    fruit: fruit ?? this.fruit,
    fruitSoft: fruitSoft ?? this.fruitSoft,
    root: root ?? this.root,
    rootSoft: rootSoft ?? this.rootSoft,
    flower: flower ?? this.flower,
    flowerSoft: flowerSoft ?? this.flowerSoft,
    leaf: leaf ?? this.leaf,
    leafSoft: leafSoft ?? this.leafSoft,
  );

  @override
  MoonColors lerp(ThemeExtension<MoonColors>? other, double t) {
    if (other is! MoonColors) return this;
    return MoonColors(
      fruit: Color.lerp(fruit, other.fruit, t)!,
      fruitSoft: Color.lerp(fruitSoft, other.fruitSoft, t)!,
      root: Color.lerp(root, other.root, t)!,
      rootSoft: Color.lerp(rootSoft, other.rootSoft, t)!,
      flower: Color.lerp(flower, other.flower, t)!,
      flowerSoft: Color.lerp(flowerSoft, other.flowerSoft, t)!,
      leaf: Color.lerp(leaf, other.leaf, t)!,
      leafSoft: Color.lerp(leafSoft, other.leafSoft, t)!,
    );
  }
}

const moonColorsLight = MoonColors(
  fruit: Color(0xFFE5484D),
  fruitSoft: Color(0xFFFDE7E8),
  root: Color(0xFF7E57C2),
  rootSoft: Color(0xFFEFE9F8),
  flower: Color(0xFFF4A91B),
  flowerSoft: Color(0xFFFDF1D6),
  leaf: Color(0xFF1E88E5),
  leafSoft: Color(0xFFE4F0FB),
);

const moonColorsDark = MoonColors(
  fruit: Color(0xFFEF6A6E),
  fruitSoft: Color(0xFF46282A),
  root: Color(0xFF9B7FD4),
  rootSoft: Color(0xFF322A44),
  flower: Color(0xFFF0B24A),
  flowerSoft: Color(0xFF453718),
  leaf: Color(0xFF5BA1E8),
  leafSoft: Color(0xFF223649),
);
