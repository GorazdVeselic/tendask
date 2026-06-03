import 'package:flutter/material.dart';

import '../../../../../core/date_format.dart';
import '../../../../../core/task_status.dart';
import '../../../../../i18n/translations.g.dart';

enum _Preset { today, tomorrow, custom }

/// Step 3 — when: quick preset (today/tomorrow/date) over explicit date + time,
/// plus the status (derived from the date, overridable). Recurrence is FR-5.
class WhenStepBody extends StatelessWidget {
  const WhenStepBody({
    super.key,
    required this.date,
    required this.status,
    required this.onSetDate,
    required this.onSetStatus,
  });

  final DateTime date;
  final TaskStatus status;
  final ValueChanged<DateTime> onSetDate;
  final ValueChanged<TaskStatus> onSetStatus;

  _Preset get _preset {
    final today = startOfDay(DateTime.now());
    final day = startOfDay(date);
    if (day == today) return _Preset.today;
    if (day == today.add(const Duration(days: 1))) return _Preset.tomorrow;
    return _Preset.custom;
  }

  DateTime _withDay(DateTime day) =>
      DateTime(day.year, day.month, day.day, date.hour, date.minute);

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) onSetDate(_withDay(picked));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: date.hour, minute: date.minute),
    );
    if (picked != null) {
      onSetDate(DateTime(
          date.year, date.month, date.day, picked.hour, picked.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        SegmentedButton<_Preset>(
          segments: [
            ButtonSegment(value: _Preset.today, label: Text(t.entry.when_today)),
            ButtonSegment(
                value: _Preset.tomorrow, label: Text(t.entry.when_tomorrow)),
            ButtonSegment(
                value: _Preset.custom, label: Text(t.entry.when_pick_date)),
          ],
          selected: {_preset},
          onSelectionChanged: (s) {
            final today = startOfDay(DateTime.now());
            switch (s.first) {
              case _Preset.today:
                onSetDate(_withDay(today));
              case _Preset.tomorrow:
                onSetDate(_withDay(today.add(const Duration(days: 1))));
              case _Preset.custom:
                _pickDate(context);
            }
          },
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _Labelled(
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
              child: _Labelled(
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
        Text(t.entry.when_default_note,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        _Labelled(
          label: t.entry.when_status,
          child: SegmentedButton<TaskStatus>(
            segments: [
              ButtonSegment(
                  value: TaskStatus.waiting,
                  label: Text(t.entry.when_status_waiting)),
              ButtonSegment(
                  value: TaskStatus.done,
                  label: Text(t.entry.when_status_done)),
            ],
            selected: {status},
            onSelectionChanged: (s) => onSetStatus(s.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 8),
        Text(t.entry.when_status_note,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        child,
      ],
    );
  }
}

class _TappableField extends StatelessWidget {
  const _TappableField(
      {required this.text, required this.icon, required this.onTap});
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
                child: Text(text,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
