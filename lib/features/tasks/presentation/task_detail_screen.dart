import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../../supplies/application/supplies_providers.dart';
import '../../weather/data/weather_snapshot.dart';
import '../../weather/presentation/weather_card.dart';
import '../application/tasks_providers.dart';
import '../data/tasks_repository.dart';
import '../../../i18n/translations.g.dart';
import 'entry/steps/reminder_step.dart';
import 'subject_labels.dart';
import 'widgets/confirm_delete_dialog.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final router = GoRouter.of(context);

    final taskAsync = ref.watch(taskByIdProvider(id));
    final catalog = ref.watch(taskTypesMapProvider).asData?.value;
    final areas = ref.watch(areasMapProvider).asData?.value;
    final repo = ref.read(tasksRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              final task = taskAsync.asData?.value;
              if (task != null) {
                _openActionMenu(context, router, task, repo);
              }
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(t.task_detail.not_found)),
        data: (task) {
          if (task == null) {
            return Center(child: Text(t.task_detail.not_found));
          }
          if (catalog == null || areas == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final taskType = catalog[task.taskTypeId];
          final isWaiting = task.status == TaskStatus.waiting;

          // Resolve the task's subjects (plants and/or areas) into one label.
          final subjects =
              ref.watch(taskSubjectsForTaskProvider(task.id)).asData?.value ??
                  const [];
          final userPlants =
              ref.watch(userPlantsMapProvider).asData?.value ?? const {};
          final plantsCatalog =
              ref.watch(plantsMapProvider).asData?.value ?? const {};
          final subjectsLabel = subjectLabelsByTask(
            subjects,
            areas: areas,
            userPlants: userPlants,
            plants: plantsCatalog,
          )[task.id];

          // Consumed supplies, e.g. "Urea 1kg, NPK 0.5kg".
          final taskSupplies =
              ref.watch(taskSuppliesProvider(task.id)).asData?.value ??
                  const [];
          final supplyById = {
            for (final s
                in ref.watch(suppliesListProvider).asData?.value ?? const [])
              s.id: s
          };
          final suppliesLabel = taskSupplies.isEmpty
              ? null
              : taskSupplies.map((ts) {
                  final s = supplyById[ts.supplyId];
                  final unit = s?.unit ?? '';
                  final amt = ts.amount == ts.amount.roundToDouble()
                      ? ts.amount.toInt().toString()
                      : ts.amount.toString();
                  return '${s?.name ?? ts.supplyId} $amt$unit';
                }).join(', ');

          // Active reminders, e.g. "1 dan prej ob 18:00, 1 ura prej".
          final reminders =
              ref.watch(remindersForTaskProvider(task.id)).asData?.value ??
                  const [];
          final remindersLabel = reminders.isEmpty
              ? null
              : reminders
                  .map((r) => reminderLabel(
                      ReminderSpec(offsetMinutes: r.offset, time: r.reminderTime),
                      t))
                  .join(', ');

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroBlock(
                        task: task,
                        taskType: taskType,
                        subjectLabel: subjectsLabel,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                          '${t.subject_picker.title} (${subjects.length})'),
                      _SubjectsCard(
                        subjects: subjects,
                        areas: areas,
                        userPlants: userPlants,
                        plants: plantsCatalog,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(t.task_detail.section_weather),
                      _WeatherSection(task: task),
                      const SizedBox(height: 20),
                      _SectionTitle(t.task_detail.section_details),
                      _DetailsCard(
                        task: task,
                        suppliesLabel: suppliesLabel,
                        remindersLabel: remindersLabel,
                      ),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                isWaiting: isWaiting,
                onComplete: () {
                  unawaited(repo.complete(id).then((_) => router.pop()));
                },
                onPostpone: () => unawaited(repo.postponeOneDay(id)),
                onEdit: () =>
                    router.pushNamed('task-edit', pathParameters: {'id': id}),
                onDuplicate: () {
                  unawaited(repo.duplicate(id).then((_) => router.pop()));
                },
                onDelete: () {
                  unawaited(repo.softDelete(id).then((_) => router.pop()));
                },
                onRevert: () => unawaited(repo.revertToWaiting(id)),
                onMove: () async {
                  final current = task.date.toLocal();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: current,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  // context not used after await — only the repo (lint-safe).
                  if (picked != null) {
                    unawaited(repo.reschedule(
                      id,
                      DateTime(picked.year, picked.month, picked.day,
                          current.hour, current.minute),
                    ));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static void _openActionMenu(
    BuildContext context,
    GoRouter router,
    Task task,
    TasksRepository repo,
  ) {
    final isWaiting = task.status == TaskStatus.waiting;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final t = ctx.t;
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              if (isWaiting) ...[
                ListTile(
                  leading: Icon(Icons.check_circle_outline,
                      color: theme.colorScheme.primary),
                  title: Text(t.task_detail.action_complete),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    unawaited(repo.complete(task.id).then((_) => router.pop()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(t.task_detail.action_postpone),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    unawaited(repo.postponeOneDay(task.id));
                  },
                ),
              ] else
                ListTile(
                  leading: Icon(Icons.undo, color: theme.colorScheme.secondary),
                  title: Text(t.task_detail.action_revert),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    unawaited(repo.revertToWaiting(task.id));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(t.task_detail.action_edit),
                onTap: () {
                  Navigator.of(ctx).pop();
                  router
                      .pushNamed('task-edit', pathParameters: {'id': task.id});
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: Text(t.task_detail.action_duplicate),
                onTap: () {
                  Navigator.of(ctx).pop();
                  unawaited(repo.duplicate(task.id).then((_) => router.pop()));
                },
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ListTile(
                leading:
                    Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(
                  t.task_detail.action_delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () async {
                  final sheetNav = Navigator.of(ctx);
                  if (await showConfirmDeleteDialog(ctx)) {
                    sheetNav.pop();
                    unawaited(
                        repo.softDelete(task.id).then((_) => router.pop()));
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ─── Hero block ───────────────────────────────────────────────────────────────

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.task,
    required this.taskType,
    required this.subjectLabel,
  });

  final Task task;
  final TaskType? taskType;
  final String? subjectLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = taskType?.icon ?? '📋';
    final label =
        taskType != null ? catalogLabel(taskType!.labels) : task.taskTypeId;
    final isWaiting = task.status == TaskStatus.waiting;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subjectLabel != null && subjectLabel!.isNotEmpty)
                Text(
                  '🪴 $subjectLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              const SizedBox(height: 6),
              _StatusPill(isWaiting: isWaiting, task: task),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isWaiting, required this.task});

  final bool isWaiting;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final local = task.date.toLocal();
    final dateStr = '${formatDmy(local)} · ${formatHm(local)}';
    final label = isWaiting
        ? '📅  ${t.task_detail.badge_waiting} · $dateStr'
        : '✓  ${t.task_detail.badge_done} · $dateStr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Subjects card ────────────────────────────────────────────────────────────

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard({
    required this.subjects,
    required this.areas,
    required this.userPlants,
    required this.plants,
  });

  final List<TaskSubject> subjects;
  final Map<String, Area> areas;
  final Map<String, UserPlant> userPlants;
  final Map<String, Plant> plants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < subjects.length; i++) ...[
            if (i > 0)
              Divider(
                  height: 1,
                  indent: 56,
                  color: theme.colorScheme.outlineVariant),
            _row(context, subjects[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, TaskSubject s) {
    final theme = Theme.of(context);
    final spec =
        TaskSubjectSpec(userPlantId: s.userPlantId, areaId: s.areaId);
    final label =
        specLabel(spec, areas: areas, userPlants: userPlants, plants: plants);
    final icon =
        specIcon(spec, areas: areas, userPlants: userPlants, plants: plants);
    // For a plant subject, show its area as a subtitle (derived from instance).
    final plantArea = s.userPlantId != null
        ? userPlants[s.userPlantId]?.areaId
        : null;
    final areaName = plantArea != null ? areas[plantArea]?.name : null;

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: areaName != null
          ? Text('🪴 $areaName',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () {
        if (s.userPlantId != null) {
          context
              .pushNamed('plant-detail', pathParameters: {'id': s.userPlantId!});
        } else if (s.areaId != null) {
          context.pushNamed('area-detail', pathParameters: {'id': s.areaId!});
        }
      },
    );
  }
}

// ─── Weather section ──────────────────────────────────────────────────────────

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final snapshot = decodeWeatherSnapshot(task.weather);
    if (snapshot != null) return WeatherSnapshotCard(snapshot: snapshot);

    // No snapshot: waiting tasks capture on completion; a done task without one
    // was logged offline (graceful — it may fill in later).
    final hint = task.status == TaskStatus.waiting
        ? t.weather.detail_waiting
        : t.weather.detail_none;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.cloud_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Details card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.task,
    required this.suppliesLabel,
    required this.remindersLabel,
  });

  final Task task;
  final String? suppliesLabel;
  final String? remindersLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final recurrenceLabel = switch (task.recurrence) {
      'weekly' => t.task_detail.recurrence_weekly,
      'seasonal' => t.task_detail.recurrence_seasonal,
      _ => t.task_detail.recurrence_once,
    };

    final local = task.date.toLocal();
    // Explicit date row, labelled by status (e.g. "Opravljeno: 3. jun · 22:00").
    final whenLabel = task.status == TaskStatus.done
        ? t.task_detail.badge_done
        : t.task_detail.badge_waiting;

    final rows = [
      (whenLabel, '${formatDmy(local)} · ${formatHm(local)}'),
      (t.task_detail.label_supplies, suppliesLabel ?? t.task_detail.none),
      (t.task_detail.label_reminder, remindersLabel ?? t.task_detail.none),
      (t.task_detail.label_recurrence, recurrenceLabel),
      if (task.note != null && task.note!.isNotEmpty)
        (t.task_detail.label_note, task.note!),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
              _InfoRow(label: rows[i].$1, value: rows[i].$2),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ─── Action bar ───────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isWaiting,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onRevert,
    required this.onMove,
  });

  final bool isWaiting;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onRevert;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary action
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isWaiting
                ? FilledButton(
                    onPressed: onComplete,
                    child: Text(t.task_detail.action_complete),
                  )
                : FilledButton.tonal(
                    onPressed: onEdit,
                    child: Text('✏️  ${t.task_detail.action_edit}'),
                  ),
          ),
          const SizedBox(height: 8),
          // Secondary row
          Row(
            children: isWaiting
                ? [
                    _SecBtn(
                      icon: Icons.schedule_outlined,
                      label: t.task_detail.action_postpone,
                      onTap: onPostpone,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.edit_outlined,
                      label: t.task_detail.action_edit,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.copy_outlined,
                      label: t.task_detail.action_duplicate,
                      onTap: onDuplicate,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.delete_outline,
                      label: t.task_detail.action_delete,
                      isDanger: true,
                      onTap: () => _confirmDelete(context),
                    ),
                  ]
                : [
                    _SecBtn(
                      icon: Icons.copy_outlined,
                      label: t.task_detail.action_duplicate,
                      onTap: onDuplicate,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.calendar_today_outlined,
                      label: t.task_detail.action_move,
                      onTap: onMove,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.undo,
                      label: t.task_detail.action_revert,
                      onTap: onRevert,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.delete_outline,
                      label: t.task_detail.action_delete,
                      isDanger: true,
                      onTap: () => _confirmDelete(context),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    unawaited(_showDeleteDialog(context));
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    if (await showConfirmDeleteDialog(context)) onDelete();
  }
}

class _SecBtn extends StatelessWidget {
  const _SecBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDanger
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isDanger
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurface;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
