import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/catalog_labels.dart';
import '../../../../../core/database/catalog_provider.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../../areas/application/areas_providers.dart';
import '../../../../plants/application/plants_providers.dart';
import '../../../application/tasks_providers.dart';
import '../../subject_labels.dart';
import '../../widgets/task_type_tile.dart';

/// Step 1 — pick the task type. Tapping a tile auto-advances (onSelect).
class TypeStepBody extends ConsumerWidget {
  const TypeStepBody({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNoteTap,
    this.onRepeatLast,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNoteTap;

  /// Pre-fill from the last task and jump to review; null in edit mode.
  final ValueChanged<String>? onRepeatLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(taskTypesMapProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        if (onRepeatLast != null) _RepeatLastCard(onTap: onRepeatLast!),
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

/// "Repeat last" shortcut card (concept backlog FR-6): pre-fills type, subjects,
/// supplies and note from the most recent task. Hidden when there is none.
class _RepeatLastCard extends ConsumerWidget {
  const _RepeatLastCard({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

    final last = ref.watch(lastTaskProvider).asData?.value;
    if (last == null) return const SizedBox.shrink();
    final type = ref.watch(taskTypesMapProvider).asData?.value[last.taskTypeId];
    if (type == null) return const SizedBox.shrink();

    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};
    final userPlants =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final labels = [
      for (final s in (ref.watch(allTaskSubjectsProvider).asData?.value ??
              const [])
          .where((s) => s.taskId == last.id))
        subjectLabel(s, areas: areas, userPlants: userPlants, plants: plants),
    ].where((l) => l.isNotEmpty);
    final summary = [
      '${type.icon} ${catalogLabel(type.labels)}',
      if (labels.isNotEmpty) labels.join(' · '),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(last.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.replay,
                    size: 20, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.entry.repeat_last,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
