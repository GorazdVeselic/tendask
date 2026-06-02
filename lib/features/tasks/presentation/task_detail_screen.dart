import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../application/tasks_providers.dart';
import '../data/tasks_repository.dart';
import '../../../i18n/translations.g.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
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
                _openActionMenu(context, router, task, repo, t, theme);
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
          final area = areas[task.areaId];
          final isWaiting = task.status == 'waiting';

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
                        area: area,
                        t: t,
                        theme: theme,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(t.task_detail.section_weather, theme: theme),
                      _WeatherPlaceholder(t: t, theme: theme),
                      const SizedBox(height: 20),
                      _SectionTitle(t.task_detail.section_details, theme: theme),
                      _DetailsCard(task: task, area: area, t: t, theme: theme),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                isWaiting: isWaiting,
                t: t,
                theme: theme,
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
    Translations t,
    ThemeData theme,
  ) {
    final isWaiting = task.status == 'waiting';
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 4),
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
                router.pushNamed('task-edit', pathParameters: {'id': task.id});
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
                final confirmed = await showDialog<bool>(
                  context: ctx,
                  builder: (dialogCtx) => AlertDialog(
                    title: Text(t.tasks_list.delete_confirm_title),
                    content: Text(t.tasks_list.delete_confirm_body),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(false),
                        child: Text(t.tasks_list.delete_cancel),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(dialogCtx).colorScheme.error,
                        ),
                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                        child: Text(t.tasks_list.delete_yes),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  sheetNav.pop();
                  unawaited(
                      repo.softDelete(task.id).then((_) => router.pop()));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Hero block ───────────────────────────────────────────────────────────────

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.task,
    required this.taskType,
    required this.area,
    required this.t,
    required this.theme,
  });

  final Task task;
  final TaskType? taskType;
  final Area? area;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleSettings.currentLocale.languageTag;
    final icon = taskType?.icon ?? '📋';
    final label = taskType != null
        ? _taskLabel(taskType!.labels, locale)
        : task.taskTypeId;
    final isWaiting = task.status == 'waiting';

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
              if (area != null)
                Text(
                  '🪴 ${area!.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              const SizedBox(height: 6),
              _StatusPill(isWaiting: isWaiting, task: task, t: t, theme: theme),
            ],
          ),
        ),
      ],
    );
  }

  static String _taskLabel(String json, String lang) {
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return (m[lang] ?? m['en'] ?? json) as String;
    } catch (_) {
      return json;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.isWaiting,
    required this.task,
    required this.t,
    required this.theme,
  });

  final bool isWaiting;
  final Task task;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final local = task.date.toLocal();
    final dateStr =
        '${local.day}. ${local.month}. ${local.year} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
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
  const _SectionTitle(this.label, {required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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

// ─── Weather placeholder ──────────────────────────────────────────────────────

class _WeatherPlaceholder extends StatelessWidget {
  const _WeatherPlaceholder({required this.t, required this.theme});

  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
                t.task_detail.weather_placeholder,
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
    required this.area,
    required this.t,
    required this.theme,
  });

  final Task task;
  final Area? area;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final recurrenceLabel = switch (task.recurrence) {
      'weekly' => t.task_detail.recurrence_weekly,
      'seasonal' => t.task_detail.recurrence_seasonal,
      _ => t.task_detail.recurrence_once,
    };

    final rows = [
      (t.task_detail.label_area, area?.name ?? t.task_detail.none),
      (t.task_detail.label_plant, t.task_detail.none), // M3.2
      (t.task_detail.label_supplies, t.task_detail.none), // M3.3
      (t.task_detail.label_reminder, t.task_detail.none), // M8
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
              _InfoRow(label: rows[i].$1, value: rows[i].$2, theme: theme),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
    required this.t,
    required this.theme,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onRevert,
  });

  final bool isWaiting;
  final Translations t;
  final ThemeData theme;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onRevert;

  @override
  Widget build(BuildContext context) {
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
                      theme: theme,
                      onTap: onPostpone,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.edit_outlined,
                      label: t.task_detail.action_edit,
                      theme: theme,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.copy_outlined,
                      label: t.task_detail.action_duplicate,
                      theme: theme,
                      onTap: onDuplicate,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.delete_outline,
                      label: t.task_detail.action_delete,
                      theme: theme,
                      isDanger: true,
                      onTap: () => _confirmDelete(context),
                    ),
                  ]
                : [
                    _SecBtn(
                      icon: Icons.copy_outlined,
                      label: t.task_detail.action_duplicate,
                      theme: theme,
                      onTap: onDuplicate,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.calendar_today_outlined,
                      label: t.task_detail.action_move,
                      theme: theme,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.undo,
                      label: t.task_detail.action_revert,
                      theme: theme,
                      onTap: onRevert,
                    ),
                    const SizedBox(width: 6),
                    _SecBtn(
                      icon: Icons.delete_outline,
                      label: t.task_detail.action_delete,
                      theme: theme,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tasks_list.delete_confirm_title),
        content: Text(t.tasks_list.delete_confirm_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.tasks_list.delete_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.tasks_list.delete_yes),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}

class _SecBtn extends StatelessWidget {
  const _SecBtn({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
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
