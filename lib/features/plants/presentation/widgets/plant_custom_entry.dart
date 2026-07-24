import 'package:flutter/material.dart';

import '../../../../core/widgets/section_label.dart';
import '../../../../i18n/translations.g.dart';

/// Offered when the search finds nothing: add the typed name as a private plant.
class PlantCustomEntry extends StatelessWidget {
  const PlantCustomEntry({
    super.key,
    required this.query,
    required this.onAdd,
  });

  final String query;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              t.plants.not_found,
              padding: const EdgeInsets.only(bottom: 6),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onAdd(query),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  t.plants.custom_add(q: query),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.plants.custom_private,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
