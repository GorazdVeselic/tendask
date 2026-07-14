import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/presentation/yield_format.dart';
import '../../tasks/yield_summary.dart';
import '../../tasks/yield_unit.dart';
import '../application/plants_providers.dart';
import '../plant_move_result.dart';
import 'plant_display.dart';
import 'widgets/area_pick_sheet.dart';

/// Read-only history of a single plant instance — the subject's home page.
class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    final plant = ref.watch(userPlantByIdProvider(id)).asData?.value;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};
    final history = ref.watch(tasksByPlantProvider(id)).asData?.value;
    final taskTypes = ref.watch(taskTypesMapProvider).asData?.value;
    final yieldSummary = history == null
        ? YieldSummary.empty
        : summarizeYield(_yieldRecords(history));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        actions: [
          if (plant != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.pushNamed('plant-edit', pathParameters: {'id': id}),
            ),
        ],
      ),
      body: plant == null
          ? Center(child: Text(t.plant_detail.not_found))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _Hero(plant: plant, catalog: catalog, areas: areas),
                if (!yieldSummary.isEmpty) ...[
                  SectionLabel(t.harvest.summary_title),
                  _YieldSummaryCard(summary: yieldSummary),
                ],
                SectionLabel(t.plant_detail.history_title),
                _History(history: history, catalog: taskTypes),
              ],
            ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({
    required this.plant,
    required this.catalog,
    required this.areas,
  });

  final UserPlant plant;
  final Map<String, Plant> catalog;
  final Map<String, Area> areas;

  Future<void> _move(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final pick = await showAreaPickSheet(
      context,
      title: t.area_pick.move_title(name: userPlantLabel(plant, catalog)),
      currentAreaId: plant.areaId,
    );
    if (pick == null || !context.mounted) return;
    // Preserve the alias — moveToArea() rewrites it, so passing the current
    // value keeps a move from clearing it.
    final res = await ref
        .read(userPlantsRepositoryProvider)
        .moveToArea(
          id: plant.id,
          areaId: pick.areaId,
          personalAlias: plant.personalAlias,
        );
    if (res == PlantMoveResult.duplicate && context.mounted) {
      showTopToast(context, t.area_pick.duplicate, error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalogPlant = plant.plantId != null ? catalog[plant.plantId] : null;
    final scientific = catalogPlant?.scientificName;
    final areaName = plant.areaId != null ? areas[plant.areaId]?.name : null;
    final pillLabel = areaName != null
        ? '$areaName · ${t.plant_detail.move}'
        : t.plant_detail.assign_area;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Text(
            userPlantIcon(plant, catalog),
            style: const TextStyle(fontSize: 26),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userPlantLabel(plant, catalog),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (scientific != null)
                Text(
                  scientific,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              ActionChip(
                avatar: Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(pillLabel),
                onPressed: () => _move(context, ref),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
      return EmptyState(t.plant_detail.history_empty);
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
      // 'task-view' (top-level), not the shell-nested 'task-detail': plant-detail
      // lives above the shell, so pushing the nested route would duplicate the
      // shell page key (BUG-004).
      onTap: () =>
          context.pushNamed('task-view', pathParameters: {'id': task.id}),
    );
  }
}

// ─── Yield summary (T11) ──────────────────────────────────────────────────────

/// Records for the yield summary: a recorded amount with a known unit. Tasks
/// without yield (non-harvest, or harvest logged without it) or with an unknown
/// unit are dropped — an unknown unit can't be aggregated.
List<YieldRecord> _yieldRecords(List<Task> tasks) => [
  for (final task in tasks)
    if (task.yieldAmount case final amount?)
      if (yieldUnitFromName(task.yieldUnit) case final unit?)
        (year: task.date.toLocal().year, amount: amount, unit: unit),
];

class _YieldSummaryCard extends StatelessWidget {
  const _YieldSummaryCard({required this.summary});

  final YieldSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Per-year rows add nothing when everything happened in one year.
    final showYears = summary.byYear.length > 1;
    final rows = <(String, String)>[
      (t.harvest.summary_total, _formatTotals(summary.totals, t)),
      if (showYears)
        for (final y in summary.byYear)
          (y.year.toString(), _formatTotals(y.totals, t)),
    ];

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _YieldRow(label: rows[i].$1, value: rows[i].$2, emphasized: i == 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _YieldRow extends StatelessWidget {
  const _YieldRow({
    required this.label,
    required this.value,
    required this.emphasized,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: emphasized
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Joins per-unit totals into one line, e.g. "12 kg · 30 kom", units in a stable
/// order so the display never reshuffles between rebuilds.
String _formatTotals(Map<YieldUnit, double> totals, Translations t) {
  final entries = totals.entries.toList()
    ..sort((a, b) => a.key.index.compareTo(b.key.index));
  return entries.map((e) => formatYield(e.value, e.key, t)).join(' · ');
}
