import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../i18n/translations.g.dart';

/// First-run garden: richer than [EmptyState] on purpose — it carries the two
/// entry points (add a plant, add an area) that seed an empty garden.
class GardenEmpty extends StatelessWidget {
  const GardenEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🌱',
              style: TextStyle(fontSize: 44, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              t.areas.empty_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.areas.empty_body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.pushNamed('plant-add'),
              icon: const Icon(Icons.add),
              label: Text(t.areas.empty_cta_plant),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed('area-new'),
              icon: const Icon(Icons.add),
              label: Text(t.areas.empty_cta_area),
            ),
          ],
        ),
      ),
    );
  }
}
