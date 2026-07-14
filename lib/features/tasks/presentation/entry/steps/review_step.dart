import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/catalog_labels.dart';
import '../../../../../core/database/catalog_provider.dart';
import '../../../../../core/date_format.dart';
import '../../../../../core/task_status.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../../areas/application/areas_providers.dart';
import '../../../../plants/application/plants_providers.dart';
import '../../../../supplies/application/supplies_providers.dart';
import '../../../../supplies/data/supply_spec.dart';
import '../../../data/recurrence.dart';
import '../../../data/tasks_repository.dart';
import '../../../yield_unit.dart';
import '../../recurrence_label.dart';
import '../../subject_labels.dart';
import '../../yield_format.dart';
import '../entry_flow.dart';
import 'reminder_step.dart';

/// Step 6 — review every choice (tap a row to jump back) plus the note.
class ReviewStepBody extends ConsumerWidget {
  const ReviewStepBody({
    super.key,
    required this.taskTypeId,
    required this.subjects,
    required this.date,
    required this.status,
    required this.recurrence,
    required this.reminders,
    required this.supplies,
    required this.noteController,
    required this.consumesSupplies,
    required this.onFix,
    required this.showYield,
    required this.yieldAmount,
    required this.yieldUnit,
    required this.onEditYield,
  });

  final String? taskTypeId;
  final List<TaskSubjectSpec> subjects;
  final DateTime date;
  final TaskStatus status;
  final Recurrence? recurrence;
  final List<ReminderSpec> reminders;
  final List<SupplySpec> supplies;
  final TextEditingController noteController;
  final bool consumesSupplies;
  final ValueChanged<EntryStep> onFix;
  // Harvest yield (T11) — shown only when logging a done harvest.
  final bool showYield;
  final double? yieldAmount;
  final YieldUnit? yieldUnit;
  final VoidCallback onEditYield;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);

    final catalog = ref.watch(taskTypesMapProvider).asData?.value ?? const {};
    final areas = ref.watch(areasMapProvider).asData?.value ?? const {};
    final userPlants =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final supplyCatalog =
        ref.watch(suppliesListProvider).asData?.value ?? const [];
    final supplyById = {for (final s in supplyCatalog) s.id: s};

    final type = taskTypeId != null ? catalog[taskTypeId] : null;
    final typeText = type != null
        ? '${type.icon}  ${catalogLabel(type.labels)}'
        : t.entry.review_none;

    final subjectText = subjects.isEmpty
        ? t.entry.review_none
        : subjects
              .map(
                (s) => specLabel(
                  s,
                  areas: areas,
                  userPlants: userPlants,
                  plants: plants,
                ),
              )
              .join(' · ');

    final statusLabel = status == TaskStatus.waiting
        ? t.entry.when_status_waiting
        : t.entry.when_status_done;

    String supplyLabel(SupplySpec spec) {
      final supply = supplyById[spec.supplyId];
      final name = supply?.name ?? spec.supplyId;
      final unit = supply?.unit ?? '';
      final amount = spec.amount == spec.amount.roundToDouble()
          ? spec.amount.toInt().toString()
          : spec.amount.toString();
      return '$name $amount$unit';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ReviewRow(
                  label: t.entry.review_type,
                  value: typeText,
                  onTap: () => onFix(EntryStep.type),
                ),
                _ReviewRow(
                  label: t.entry.review_subject,
                  value: subjectText,
                  onTap: () => onFix(EntryStep.subject),
                ),
                _ReviewRow(
                  label: t.entry.review_when,
                  value: '${formatDmy(date)} · ${formatHm(date)}',
                  sub: statusLabel,
                  onTap: () => onFix(EntryStep.when),
                ),
                if (showYield)
                  _ReviewRow(
                    label: t.harvest.yield_section,
                    value: (yieldAmount != null && yieldUnit != null)
                        ? formatYield(yieldAmount!, yieldUnit, t)
                        : t.harvest.add,
                    onTap: onEditYield,
                    last: !consumesSupplies,
                  ),
                if (status == TaskStatus.waiting && recurrence != null)
                  _ReviewRow(
                    label: t.entry.recurrence_label,
                    value: recurrenceLabel(t, recurrence),
                    onTap: () => onFix(EntryStep.when),
                  ),
                if (status == TaskStatus.waiting)
                  _ReviewRow(
                    label: t.entry.review_reminder,
                    value: reminders.isEmpty
                        ? t.entry.review_none
                        : reminders.map((r) => reminderLabel(r, t)).join(' · '),
                    onTap: () => onFix(EntryStep.reminder),
                  ),
                if (consumesSupplies)
                  _ReviewRow(
                    label: t.entry.review_supplies,
                    value: supplies.isEmpty
                        ? t.entry.review_none
                        : supplies.map(supplyLabel).join(' · '),
                    onTap: () => onFix(EntryStep.supplies),
                    last: true,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${t.entry.note_label} ${t.entry.optional}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            hintText: t.entry.note_hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        Text(
          t.entry.weather_note,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.sub,
    this.last = false,
  });

  final String label;
  final String value;
  final String? sub;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: last
            ? null
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 78,
              child: Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.bodyMedium),
                  if (sub != null)
                    Text(
                      sub!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${t.entry.review_fix} ›',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
