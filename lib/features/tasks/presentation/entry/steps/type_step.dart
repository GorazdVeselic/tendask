import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/catalog_labels.dart';
import '../../../../../core/database/catalog_provider.dart';
import '../../../../../i18n/translations.g.dart';
import '../../widgets/task_type_tile.dart';

/// Step 1 — pick the task type. Tapping a tile auto-advances (onSelect).
class TypeStepBody extends ConsumerWidget {
  const TypeStepBody({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNoteTap,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNoteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(taskTypesMapProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        catalogAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Icon(Icons.error_outline,
                  color: theme.colorScheme.error),
            ),
          ),
          data: (catalog) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: catalog.length,
            itemBuilder: (context, i) {
              final type = catalog.values.elementAt(i);
              return TaskTypeTile(
                icon: type.icon,
                label: catalogLabel(type.labels),
                selected: type.id == selected,
                onTap: () => onSelect(type.id),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '💡 ${t.entry.type_hint}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onNoteTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Text('✍️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t.entry.note_card_title,
                        style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    t.entry.note_card_action,
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
