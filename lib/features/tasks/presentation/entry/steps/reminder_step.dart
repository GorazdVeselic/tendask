import 'package:flutter/material.dart';

import '../../../../../i18n/translations.g.dart';
import '../../../data/tasks_repository.dart';

/// Human label for a reminder spec, e.g. "1 dan prej ob 18:00".
String reminderLabel(ReminderSpec r, Translations t) {
  final base = switch (r.offsetMinutes) {
    0 => t.entry.rem_event,
    10 => t.entry.rem_10min,
    60 => t.entry.rem_1hour,
    1440 => t.entry.rem_1day,
    2880 => t.entry.rem_2day,
    _ => t.entry.rem_event,
  };
  if (r.offsetMinutes >= 1440 && r.time != null) {
    return '$base ${t.entry.rem_at(t: r.time!)}';
  }
  return base;
}

/// Step 4 — reminders (notifications). Shown only when the task is waiting.
/// Persists the model; actual scheduling lands in M8.
class ReminderStepBody extends StatelessWidget {
  const ReminderStepBody({
    super.key,
    required this.reminders,
    required this.taskDate,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ReminderSpec> reminders;
  final DateTime taskDate;
  final ValueChanged<ReminderSpec> onAdd;
  final ValueChanged<int> onRemove;

  Future<void> _add(BuildContext context) async {
    final spec = await showReminderEditSheet(context, taskDate);
    if (spec != null) onAdd(spec);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(t.entry.reminder_why,
                      style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < reminders.length; i++)
                ListTile(
                  dense: true,
                  leading: const Text('🔔', style: TextStyle(fontSize: 18)),
                  title: Text(reminderLabel(reminders[i], t),
                      style: theme.textTheme.bodyMedium),
                  trailing: IconButton(
                    icon: Icon(Icons.close,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: () => onRemove(i),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t.entry.reminder_add),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(t.entry.reminder_note,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ─── Edit sheet ──────────────────────────────────────────────────────────────

Future<ReminderSpec?> showReminderEditSheet(
    BuildContext context, DateTime taskDate) {
  return showModalBottomSheet<ReminderSpec>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReminderEditSheet(taskDate: taskDate),
  );
}

/// Offset presets in minutes; day-based offsets (>= 1440) carry a time of day.
const _offsets = [0, 10, 60, 1440, 2880];

class _ReminderEditSheet extends StatefulWidget {
  const _ReminderEditSheet({required this.taskDate});
  final DateTime taskDate;

  @override
  State<_ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends State<_ReminderEditSheet> {
  int _offset = 1440;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);

  bool get _isDayBased => _offset >= 1440;

  String _label(int offset, Translations t) => switch (offset) {
        0 => t.entry.rem_event,
        10 => t.entry.rem_10min,
        60 => t.entry.rem_1hour,
        1440 => t.entry.rem_1day,
        2880 => t.entry.rem_2day,
        _ => t.entry.rem_event,
      };

  String get _timeText =>
      '${_time.hour.toString().padLeft(2, '0')}:'
      '${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _confirm() {
    Navigator.of(context).pop(ReminderSpec(
      offsetMinutes: _offset,
      time: _isDayBased ? _timeText : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.entry.reminder_title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            RadioGroup<int>(
              groupValue: _offset,
              onChanged: (v) => setState(() => _offset = v ?? _offset),
              child: Column(
                children: [
                  for (final offset in _offsets)
                    RadioListTile<int>(
                      value: offset,
                      title: Text(_label(offset, t)),
                      secondary:
                          const Text('🔔', style: TextStyle(fontSize: 16)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            if (_isDayBased) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(child: Text(t.entry.rem_choose_time)),
                  TextButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time_outlined, size: 18),
                    label: Text(_timeText),
                  ),
                ],
              ),
              Text(t.entry.rem_time_note,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _confirm,
                child: Text(t.entry.reminder_add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
