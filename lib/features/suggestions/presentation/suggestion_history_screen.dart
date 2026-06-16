import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/suggestion_status.dart';
import '../../../core/widgets/day_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../application/suggestion_providers.dart';
import 'suggestion_text.dart';

/// Read-only audit timeline of past suggestions and how the user responded
/// (M11.13b). Grouped by the day of the response (`updated_at`), newest first.
/// Not a notification center (koncept §7.12) — it strengthens explainability
/// ("why did I get this"). Planned/logged rows link to the created task.
class SuggestionHistoryScreen extends ConsumerWidget {
  const SuggestionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final history = ref.watch(suggestionHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.suggestions.past_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: switch (history) {
          AsyncData(:final value) when value.isEmpty => EmptyState(
            t.suggestions.past_empty,
          ),
          AsyncData(:final value) => _HistoryList(rows: value),
          // A local DB read failure is a bug — surface it quietly, never shrink.
          AsyncError() => _ErrorHint(t.common.load_error),
          _ => const Center(child: CircularProgressIndicator.adaptive()),
        },
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.rows});

  final List<Suggestion> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final taskTypes = ref.watch(taskTypesMapProvider).asData?.value ?? const {};
    final userPlants =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};

    final groups = _groupByDay(rows);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      // +2: leading intro hint, trailing retention note.
      itemCount: groups.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              t.suggestions.past_intro,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        if (i == groups.length + 1) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              t.suggestions.past_retention,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final group = groups[i - 1];
        return _DayGroup(
          date: group.date,
          rows: group.rows,
          taskTypes: taskTypes,
          userPlants: userPlants,
          plants: plants,
          areas: areas,
        );
      },
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.date,
    required this.rows,
    required this.taskTypes,
    required this.userPlants,
    required this.plants,
    required this.areas,
  });

  final DateTime date;
  final List<Suggestion> rows;
  final Map<String, TaskType> taskTypes;
  final Map<String, UserPlant> userPlants;
  final Map<String, Plant> plants;
  final Map<String, Area> areas;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DayHeader(date),
          const SizedBox(height: 6),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  _HistoryRow(
                    suggestion: rows[i],
                    taskType: taskTypes[rows[i].taskTypeId],
                    subject: suggestionSubjectLabel(
                      rows[i],
                      userPlants,
                      plants,
                      areas,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.suggestion,
    required this.taskType,
    required this.subject,
  });

  final Suggestion suggestion;
  final TaskType? taskType;
  final String subject;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final taskLabel = taskType != null
        ? catalogLabel(taskType!.labels)
        : suggestion.taskTypeId;
    final icon = taskType?.icon ?? '🌱';
    final params = suggestionDisplayParams(
      suggestion,
      subject: subject,
      task: taskLabel,
    );
    final title =
        suggestionMessage(t, '${suggestion.messageKey}.title', params) ??
        taskLabel;

    // Planned/logged both link to the created task (planned_task_id holds it).
    final taskId = suggestion.plannedTaskId;
    final linksTask =
        taskId != null &&
        (suggestion.status == kSuggestionPlanned ||
            suggestion.status == kSuggestionLogged);

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: subject.isNotEmpty
          ? Text(
              '🪴 $subject',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusChip(suggestion),
          if (linksTask)
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: linksTask
          // 'task-view' (top-level), not the shell-nested 'task-detail': this
          // screen lives above the shell, so pushing the nested route would
          // duplicate the shell page key and crash the navigator.
          ? () => context.pushNamed('task-view', pathParameters: {'id': taskId})
          : null,
    );
  }
}

/// Status pill: positive responses (planned/logged) in the brand container tone,
/// expired ("missed") in the honey accent, dismissals in a muted outline.
class _StatusChip extends StatelessWidget {
  const _StatusChip(this.suggestion);

  final Suggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hs = context.t.suggestions.history_status;

    final (String label, Color? bg, Color fg, bool outlined) = switch (suggestion
        .status) {
      kSuggestionPlanned => (
        hs.planned,
        cs.primaryContainer,
        cs.onPrimaryContainer,
        false,
      ),
      kSuggestionLogged => (
        hs.logged,
        cs.primaryContainer,
        cs.onPrimaryContainer,
        false,
      ),
      kSuggestionExpired => (hs.missed, cs.secondary, cs.onSecondary, false),
      kSuggestionDismissed
          when suggestion.dismissScope == kDismissScopeForever =>
        (hs.muted, null, cs.onSurfaceVariant, true),
      // dismissed for the season (and any unexpected status, defensively).
      _ => (hs.dismissed, null, cs.onSurfaceVariant, true),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: outlined ? Border.all(color: cs.outline) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Quiet centered indicator for a local read failure — not a full error screen.
class _ErrorHint extends StatelessWidget {
  const _ErrorHint(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DayBucket {
  _DayBucket(this.date, this.rows);
  final DateTime date;
  final List<Suggestion> rows;
}

/// Groups already-sorted (updated_at desc) rows into contiguous day buckets.
List<_DayBucket> _groupByDay(List<Suggestion> rows) {
  final out = <_DayBucket>[];
  for (final s in rows) {
    final day = startOfDay(s.updatedAt.toLocal());
    if (out.isNotEmpty && out.last.date == day) {
      out.last.rows.add(s);
    } else {
      out.add(_DayBucket(day, [s]));
    }
  }
  return out;
}
