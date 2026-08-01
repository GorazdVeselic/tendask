import 'package:flutter/material.dart';

import '../../../../app/theme/moon_colors.dart';
import '../../../../core/biodynamic/biodynamic_day.dart';
import '../../../../i18n/translations.g.dart';

/// Emoji glyph of a biodynamic element (FR-19, decision A5 fallback: emoji,
/// same set as the wireframes). One constant for every surface that shows an
/// element glyph.
String elementEmoji(BiodynamicElement element) => switch (element) {
      BiodynamicElement.fruit => '🍅',
      BiodynamicElement.root => '🥕',
      BiodynamicElement.flower => '🌸',
      BiodynamicElement.leaf => '🌿',
    };

/// Pill badge naming an element day ("dan za plod"): element emoji on the
/// element's soft tone, label in onSurface (contrast rule A4). Glyph + label
/// always travel together — never colour alone (accessibility).
class ElementBadge extends StatelessWidget {
  const ElementBadge({super.key, required this.element});

  final BiodynamicElement element;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soft = MoonColors.of(context).softOf(element);
    // Map completeness against BiodynamicElement is enforced by i18n tests.
    final label = context.t.moon.day_for[element.name]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(elementEmoji(element), style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
