import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';

/// Blurs [child] into an inert preview and puts a calm "Available in Tendask +"
/// card beneath it (wireframe community-flow_v3 C1/C2). Deliberately carries no
/// price, store link or call to buy — the purchase lives entirely outside the app
/// (FR-20 §3.1 anti-steering).
class TeaseOverlay extends StatelessWidget {
  const TeaseOverlay({super.key, this.child});

  /// Content being teased; shown blurred and non-interactive. Null shows the
  /// card alone (nothing worth previewing, e.g. a one-row feed).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final preview = child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (preview != null)
          ExcludeSemantics(
            child: IgnorePointer(
              child: ImageFiltered(
                // decal: without it the blur samples past the edges and smears.
                imageFilter: ImageFilter.blur(
                  sigmaX: 6,
                  sigmaY: 6,
                  tileMode: TileMode.decal,
                ),
                child: preview,
              ),
            ),
          ),
        const _TeaseCard(),
      ],
    );
  }
}

class _TeaseCard extends StatelessWidget {
  const _TeaseCard();

  @override
  Widget build(BuildContext context) {
    final t = context.t.community.tease;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hexagon_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t.body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              // Inert until FR-20 adds the redeem-code screen — there is nothing
              // to redeem against yet, and the app never links out to buy.
              child: FilledButton(onPressed: null, child: Text(t.redeem)),
            ),
          ],
        ),
      ),
    );
  }
}
