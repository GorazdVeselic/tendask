import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/presentation/garden_plant_add_screen.dart';
import '../../plants/presentation/widgets/plant_row.dart';
import '../../tasks/presentation/yield_format.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';

class AreaDetailScreen extends ConsumerWidget {
  const AreaDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

    final area = ref.watch(areaByIdProvider(id)).asData?.value;
    final history = ref.watch(areaHistoryProvider(id)).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final plants = ref.watch(userPlantsByAreaProvider(id)).asData?.value;
    final plantCatalog = ref.watch(plantsMapProvider).asData?.value ?? const {};

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        actions: [
          if (area != null)
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _openActionSheet(context, ref, area),
            ),
        ],
      ),
      body: area == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : SlidableAutoCloseBehavior(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _Hero(area: area),
                  const SizedBox(height: 8),
                  SectionLabel(t.areas.plants_section),
                  if (plants != null)
                    for (final p in plants)
                      PlantRow(plant: p, catalog: plantCatalog),
                  ListTile(
                    leading: Icon(Icons.add, color: theme.colorScheme.primary),
                    title: Text(
                      t.areas.add_plant_here(area: area.name),
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    onTap: () => context.pushNamed(
                      'plant-add',
                      extra: PlantAddArgs(areaId: id),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SectionLabel(t.areas.history_title),
                  const SizedBox(height: 4),
                  _History(history: history, catalog: catalog),
                ],
              ),
            ),
    );
  }

  void _openActionSheet(BuildContext context, WidgetRef ref, Area area) {
    final t = context.t;
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(t.areas.action_edit),
              onTap: () {
                Navigator.of(ctx).pop();
                context.pushNamed('area-edit', pathParameters: {'id': area.id});
              },
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                t.areas.action_delete,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                final sheetNav = Navigator.of(ctx);
                final confirmed = await showConfirmDialog(
                  context,
                  title: t.areas.delete_confirm_title,
                  body: t.areas.delete_confirm_body,
                  confirmLabel: t.areas.action_delete,
                  cancelLabel: t.tasks_list.delete_cancel,
                );
                if (!confirmed) return;
                await ref.read(areasRepositoryProvider).softDelete(area.id);
                sheetNav.pop();
                if (context.mounted) context.pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.area});

  final Area area;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Text(
            areaTypeIcon(area.type),
            style: const TextStyle(fontSize: 26),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                area.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                areaTypeLabel(area.type, t),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── History ──────────────────────────────────────────────────────────────────

class _History extends StatelessWidget {
  const _History({required this.history, required this.catalog});

  final List<Task>? history;
  final Map<String, TaskType>? catalog;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final tasks = history;
    if (tasks == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (tasks.isEmpty) {
      return EmptyState(t.areas.history_empty);
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
            _HistoryRow(task: tasks[i], catalog: catalog),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.task, required this.catalog});

  final Task task;
  final Map<String, TaskType>? catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = catalog?[task.taskTypeId];
    final label = type != null ? catalogLabel(type.labels) : task.taskTypeId;
    final icon = type?.icon ?? '📋';
    final yieldChip = taskYieldChip(task, context.t);

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: yieldChip != null
          ? Text(
              yieldChip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Text(
        formatDmy(task.date.toLocal()),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
