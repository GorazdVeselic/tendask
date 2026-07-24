import 'package:flutter/material.dart';

import '../../../../core/widgets/removable_chip.dart';
import '../../../../i18n/translations.g.dart';
import '../plant_picker_view.dart';

/// Sticky footer of the plant picker: how many the target holds, chips to remove
/// them again, and "Done".
class PlantAddedBar extends StatelessWidget {
  const PlantAddedBar({
    super.key,
    required this.added,
    required this.onRemove,
    required this.onDone,
  });

  final List<PickedPlant> added;
  final void Function(PickedPlant) onRemove;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Newest first so the latest add sits at the front without scrolling.
    final items = added.reversed.toList();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${added.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => RemovableChip(
                        label: items[i].label,
                        onRemove: () => onRemove(items[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDone,
                child: Text(t.plants.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
