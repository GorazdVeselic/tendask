import 'package:flutter/material.dart';

import '../../../../app/theme/theme_palette.dart';
import '../../../../i18n/translations.g.dart';
import '../palette_labels.dart';

/// A tappable palette card: a mini-preview (the palette's own colours in the
/// current brightness), its name, a "Default" badge for green, and a corner
/// check when selected.
class PaletteCard extends StatelessWidget {
  const PaletteCard({
    super.key,
    required this.palette,
    required this.roles,
    required this.isSelected,
    required this.isDefault,
    required this.onTap,
  });

  final ThemePalette palette;
  final ThemeRoles roles;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outline,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniPreview(roles: roles),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        paletteName(palette.id, t),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.appearance.default_badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 14, color: cs.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tiny static mock (app bar + body row) painted in a specific palette's
/// roles — independent of the screen's own theme.
class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.roles});

  final ThemeRoles roles;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 50,
        child: Column(
          children: [
            Container(
              height: 17,
              color: roles.primary,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: roles.onPrimary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: roles.surface,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 9,
                      decoration: BoxDecoration(
                        color: roles.secondary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 9,
                        decoration: BoxDecoration(
                          color: roles.onSurface.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
