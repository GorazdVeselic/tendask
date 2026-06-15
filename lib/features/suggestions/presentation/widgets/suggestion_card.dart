import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog_labels.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/catalog_provider.dart';
import '../../../../core/task_status.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../areas/application/areas_providers.dart';
import '../../../plants/application/plants_providers.dart';
import '../../../tasks/application/tasks_providers.dart';
import '../../../tasks/data/tasks_repository.dart';
import '../../application/suggestion_providers.dart';
import '../../data/suggestion_repository.dart';
import '../suggestion_text.dart';

/// One smart-suggestion card on the Home band: icon + title/body (filled from
/// the engine's message_params), Plan / Skip, and a ⋯ menu for the rarer
/// "already done" / "never" / "remove subject" actions. Read-only on the data;
/// every decision is a local drift write via [SuggestionRepository].
class SuggestionCard extends ConsumerStatefulWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.highlighted = false,
  });

  final Suggestion suggestion;

  /// True while a deep-linked push briefly highlights this card (cleared by the
  /// band after ~2 s).
  final bool highlighted;

  @override
  ConsumerState<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends ConsumerState<SuggestionCard> {
  // Guards against a double-tap creating two tasks: the card stays visible until
  // the watchActive stream drops it (a brief latency), so we disable the actions
  // for the duration of the in-flight one.
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    final highlighted = widget.highlighted;
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final taskTypes = ref.watch(taskTypesMapProvider).asData?.value ?? const {};
    final userPlants =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};

    final taskType = taskTypes[suggestion.taskTypeId];
    final taskLabel = taskType != null
        ? catalogLabel(taskType.labels)
        : suggestion.taskTypeId;
    final icon = taskType?.icon ?? '🌱';
    final subject = suggestionSubjectLabel(
      suggestion,
      userPlants,
      plants,
      areas,
    );

    final params = suggestionDisplayParams(
      suggestion,
      subject: subject,
      task: taskLabel,
    );
    final title =
        suggestionMessage(t, '${suggestion.messageKey}.title', params) ??
        taskLabel;
    final body =
        suggestionMessage(t, '${suggestion.messageKey}.body', params) ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 2),
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () =>
                                _showActions(context, ref, suggestion, subject),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => _dismiss(ref, suggestion)),
                    child: Text(t.suggestions.actions.dismiss),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => _plan(context, ref, suggestion)),
                    child: Text(t.suggestions.actions.plan),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<TaskSubjectSpec> _subjectsOf(Suggestion s) => [
  if (s.userPlantId != null)
    TaskSubjectSpec.plant(s.userPlantId!)
  else if (s.areaId != null)
    TaskSubjectSpec.area(s.areaId!),
];

/// The engine ships the action date in message_params; the client only reads it
/// (fallback tomorrow 09:00 when missing). 09:00 local; the repo normalizes UTC.
DateTime _suggestedDate(Suggestion s) {
  try {
    final p = jsonDecode(s.messageParams) as Map<String, dynamic>;
    final d = DateTime.tryParse(p['suggested_date']?.toString() ?? '');
    if (d != null) return DateTime(d.year, d.month, d.day, 9);
  } catch (_) {
    /* fall through */
  }
  final t = DateTime.now().add(const Duration(days: 1));
  return DateTime(t.year, t.month, t.day, 9);
}

Future<void> _plan(BuildContext context, WidgetRef ref, Suggestion s) async {
  final taskId = await ref
      .read(tasksRepositoryProvider)
      .create(
        userId: ref.read(authServiceProvider).userId,
        taskTypeId: s.taskTypeId,
        date: _suggestedDate(s),
        subjects: _subjectsOf(s),
      );
  await ref
      .read(suggestionRepositoryProvider)
      .markPlanned(s.id, plannedTaskId: taskId);
  if (!context.mounted) return;
  showTopToast(context, context.t.suggestions.toast.planned);
}

Future<void> _dismiss(
  WidgetRef ref,
  Suggestion s, {
  DismissScope scope = DismissScope.season,
}) => ref.read(suggestionRepositoryProvider).dismiss(s.id, scope: scope);

Future<void> _showActions(
  BuildContext context,
  WidgetRef ref,
  Suggestion s,
  String subjectLabel,
) async {
  final hasSubject = s.userPlantId != null || s.areaId != null;
  final action = await showModalBottomSheet<String>(
    context: context,
    // Push on the root navigator so the modal sits above the shell's FAB and
    // bottom nav (otherwise the centre FAB paints over the sheet rows).
    useRootNavigator: true,
    builder: (ctx) {
      final t = ctx.t;
      final cs = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(t.suggestions.actions.already_done),
              onTap: () => Navigator.pop(ctx, 'done'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: Text(t.suggestions.actions.never),
              onTap: () => Navigator.pop(ctx, 'never'),
            ),
            if (hasSubject) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete_outline, color: cs.error),
                title: Text(
                  t.suggestions.actions.remove_subject,
                  style: TextStyle(color: cs.error),
                ),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'done':
      await _alreadyDone(context, ref, s);
    case 'never':
      await _dismiss(ref, s, scope: DismissScope.forever);
    case 'remove':
      await _removeSubject(context, ref, s, subjectLabel);
  }
}

Future<void> _alreadyDone(
  BuildContext context,
  WidgetRef ref,
  Suggestion s,
) async {
  final date = await _pickDoneDate(context);
  if (date == null || !context.mounted) return;
  final taskId = await ref
      .read(tasksRepositoryProvider)
      .create(
        userId: ref.read(authServiceProvider).userId,
        taskTypeId: s.taskTypeId,
        date: date,
        subjects: _subjectsOf(s),
        status: TaskStatus.done,
      );
  await ref
      .read(suggestionRepositoryProvider)
      .markLogged(s.id, doneTaskId: taskId);
  if (!context.mounted) return;
  showTopToast(context, context.t.suggestions.toast.logged);
}

/// Mini-sheet to date the "already done" task: today / yesterday / pick. Returns
/// the chosen day at local noon (avoids midnight timezone edges), or null.
Future<DateTime?> _pickDoneDate(BuildContext context) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) {
      final t = ctx.t;
      final theme = Theme.of(ctx);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.suggestions.done_sheet.title,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
            ListTile(
              title: Text(t.suggestions.done_sheet.today),
              onTap: () => Navigator.pop(ctx, 'today'),
            ),
            ListTile(
              title: Text(t.suggestions.done_sheet.yesterday),
              onTap: () => Navigator.pop(ctx, 'yesterday'),
            ),
            ListTile(
              title: Text(t.suggestions.done_sheet.pick),
              onTap: () => Navigator.pop(ctx, 'pick'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
  if (choice == null) return null;
  final now = DateTime.now();
  DateTime atNoon(DateTime d) => DateTime(d.year, d.month, d.day, 12);
  switch (choice) {
    case 'today':
      return atNoon(now);
    case 'yesterday':
      return atNoon(now.subtract(const Duration(days: 1)));
    case 'pick':
      if (!context.mounted) return null;
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
      );
      return picked == null ? null : atNoon(picked);
  }
  return null;
}

Future<void> _removeSubject(
  BuildContext context,
  WidgetRef ref,
  Suggestion s,
  String subjectLabel,
) async {
  final t = context.t;
  final confirmed = await showConfirmDialog(
    context,
    title: t.suggestions.remove.title,
    body: fillTemplate(t.suggestions.remove.body, {'subject': subjectLabel}),
    confirmLabel: t.suggestions.remove.confirm,
    cancelLabel: t.tasks_list.delete_cancel,
    destructive: true,
  );
  if (!confirmed) return;
  if (s.userPlantId != null) {
    await ref.read(userPlantsRepositoryProvider).softDelete(s.userPlantId!);
  } else if (s.areaId != null) {
    await ref.read(areasRepositoryProvider).softDelete(s.areaId!);
  }
  // The subject is gone; dismiss retires the card (watchActive also filters it).
  await _dismiss(ref, s);
}
