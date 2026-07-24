import 'package:flutter/material.dart';

import '../../../../../core/date_format.dart';
import '../../../../../core/task_status.dart';
import '../../../../../core/widgets/section_label.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../data/recurrence.dart';
import '../widgets/recurrence_picker.dart';
import 'when_rules.dart';

/// Step 3 — when: quick preset (today/tomorrow/date) over explicit date + time,
/// the status (derived from the date, overridable), and recurrence (FR-5) shown
/// only for a waiting (future) task.
class WhenStepBody extends StatelessWidget {
  const WhenStepBody({
    super.key,
    required this.date,
    required this.status,
    required this.recurrence,
    required this.onSetDate,
    required this.onSetStatus,
    required this.onSetRecurrence,
  });

  final DateTime date;
  final TaskStatus status;
  final Recurrence? recurrence;
  final ValueChanged<DateTime> onSetDate;
  final ValueChanged<TaskStatus> onSetStatus;

  /// (rule, valid): valid == false when a shown number field is empty/invalid.
  final void Function(Recurrence? rule, bool valid) onSetRecurrence;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) onSetDate(combineDateAndTime(picked, date));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: date.hour, minute: date.minute),
    );
    if (picked != null) {
      onSetDate(
        DateTime(date.year, date.month, date.day, picked.hour, picked.minute),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        SegmentedButton<WhenPreset>(
          segments: [
            ButtonSegment(
              value: WhenPreset.today,
              label: Text(t.entry.when_today),
            ),
            ButtonSegment(
              value: WhenPreset.tomorrow,
              label: Text(t.entry.when_tomorrow),
            ),
            ButtonSegment(
              value: WhenPreset.custom,
              label: Text(t.entry.when_pick_date),
            ),
          ],
          selected: {whenPreset(date, DateTime.now())},
          showSelectedIcon: false,
          onSelectionChanged: (s) {
            final picked = dateForPreset(s.first, date, DateTime.now());
            if (picked == null) {
              _pickDate(context);
            } else {
              onSetDate(picked);
            }
          },
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _Field(
                label: t.entry.when_date,
                child: _TappableField(
                  text: formatDmy(date),
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _pickDate(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _Field(
                label: t.entry.when_time,
                child: _TappableField(
                  text: formatHm(date),
                  icon: Icons.access_time_outlined,
                  onTap: () => _pickTime(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          t.entry.when_default_note,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _Field(
          label: t.entry.when_status,
          child: SegmentedButton<TaskStatus>(
            segments: [
              ButtonSegment(
                value: TaskStatus.waiting,
                label: Text(t.entry.when_status_waiting),
              ),
              ButtonSegment(
                value: TaskStatus.done,
                label: Text(t.entry.when_status_done),
              ),
            ],
            selected: {status},
            showSelectedIcon: false,
            onSelectionChanged: (s) => onSetStatus(s.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.entry.when_status_note,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        // Recurrence only makes sense for a planned (waiting) task (§7.9).
        if (status == TaskStatus.waiting) ...[
          const SizedBox(height: 20),
          // No ValueKey here: the picker owns its state after mount. Keying it on
          // `recurrence` would rebuild it (resetting the mode) on every keystroke,
          // since each edit emits a new rule. Edit-load is safe because the step
          // is first built only after the task loads (the _isLoading gate).
          RecurrencePicker(
            recurrence: recurrence,
            anchorDate: date,
            onChanged: onSetRecurrence,
          ),
        ],
      ],
    );
  }
}

/// A form field under its label.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [FieldLabel(label), child],
  );
}

class _TappableField extends StatelessWidget {
  const _TappableField({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
