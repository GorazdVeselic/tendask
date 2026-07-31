import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Fixed semantic colours of the four moon calendar elements (FR-19, decision
/// A4): one light + one dark instance shared by all six palettes, so an element
/// keeps its recognisable colour regardless of the chosen palette. Strong tone
/// = icon/label accent, soft tone = calendar cell / chip background. Values
/// live in [AppColors] (the app-wide colour constants home); widgets read them
/// via `Theme.of(context).extension<MoonColors>()`, never hardcoded hex.
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
  fruit: AppColors.moonFruit,
  fruitSoft: AppColors.moonFruitSoft,
  root: AppColors.moonRoot,
  rootSoft: AppColors.moonRootSoft,
  flower: AppColors.moonFlower,
  flowerSoft: AppColors.moonFlowerSoft,
  leaf: AppColors.moonLeaf,
  leafSoft: AppColors.moonLeafSoft,
);

const moonColorsDark = MoonColors(
  fruit: AppColors.moonFruitDark,
  fruitSoft: AppColors.moonFruitContainerDark,
  root: AppColors.moonRootDark,
  rootSoft: AppColors.moonRootContainerDark,
  flower: AppColors.moonFlowerDark,
  flowerSoft: AppColors.moonFlowerContainerDark,
  leaf: AppColors.moonLeafDark,
  leafSoft: AppColors.moonLeafContainerDark,
);
