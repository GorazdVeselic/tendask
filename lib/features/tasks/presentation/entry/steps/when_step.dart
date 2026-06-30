import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/config.dart';
import '../../../../../core/date_format.dart';
import '../../../../../core/task_status.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../data/recurrence.dart';

enum _Preset { today, tomorrow, custom }

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
        SegmentedButton<_Preset>(
          segments: [
            ButtonSegment(
              value: _Preset.today,
              label: Text(t.entry.when_today),
            ),
            ButtonSegment(
              value: _Preset.tomorrow,
              label: Text(t.entry.when_tomorrow),
            ),
            ButtonSegment(
              value: _Preset.custom,
              label: Text(t.entry.when_pick_date),
            ),
          ],
          selected: {_preset},
          showSelectedIcon: false,
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
        Text(
          t.entry.when_default_note,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _Labelled(
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
          _RecurrencePicker(
            recurrence: recurrence,
            anchorDate: date,
            onChanged: onSetRecurrence,
          ),
        ],
      ],
    );
  }
}

enum _RecMode { off, daily, weekly, custom }

/// Width of the small numeric inputs (interval / repeat count) in the picker.
const double _kNumberFieldWidth = 64;

_RecMode _modeOf(Recurrence? r) {
  if (r == null) return _RecMode.off;
  if (r.everyDays == 1) return _RecMode.daily;
  if (r.everyDays == 7) return _RecMode.weekly;
  return _RecMode.custom;
}

/// The recurrence sub-form: frequency (off/daily/weekly/custom), a custom
/// interval, and an optional total-occurrences cap. Stateful so the text fields
/// keep their own controllers; emits a [Recurrence] (or null) on every change.
class _RecurrencePicker extends StatefulWidget {
  const _RecurrencePicker({
    required this.recurrence,
    required this.anchorDate,
    required this.onChanged,
  });

  final Recurrence? recurrence;

  /// The task's scheduled date — the next occurrence is shown relative to it.
  final DateTime anchorDate;

  /// Emits the current rule (null = off) and whether the inputs are complete.
  /// `valid == false` means a shown number field is empty/out of range — the
  /// caller must block "Continue" until it is fixed.
  final void Function(Recurrence? rule, bool valid) onChanged;

  @override
  State<_RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<_RecurrencePicker> {
  late _RecMode _mode;
  late final TextEditingController _interval;
  late bool _limited;
  late final TextEditingController _count;

  @override
  void initState() {
    super.initState();
    final r = widget.recurrence;
    _mode = _modeOf(r);
    // r is non-null whenever the mode is custom (see _modeOf), so r! is safe.
    _interval = TextEditingController(
      text: _mode == _RecMode.custom
          ? '${r!.everyDays}'
          : '$kRecurrenceDefaultIntervalDays',
    );
    final remaining = r?.remaining;
    _limited = remaining != null;
    // Field is the number of repeats == remaining (how many follow this one).
    _count = TextEditingController(
      text: '${remaining ?? kRecurrenceDefaultRepeats}',
    );
    // Sync the caller's validity once mounted (e.g. after a status flip remounts
    // this picker) without calling setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _emit();
    });
  }

  @override
  void dispose() {
    _interval.dispose();
    _count.dispose();
    super.dispose();
  }

  // A custom interval of >= 1 day. Null when the field is empty/invalid.
  int? get _intervalDays =>
      _mode == _RecMode.custom ? int.tryParse(_interval.text) : null;
  // The number of repeats (>= 1) when capped. Null when the field is empty/invalid.
  int? get _repeats => int.tryParse(_count.text);

  bool get _intervalInvalid {
    if (_mode != _RecMode.custom) return false;
    final d = _intervalDays;
    return d == null || d < 1;
  }

  bool get _countInvalid {
    if (!_limited) return false;
    final r = _repeats;
    return r == null || r < 1;
  }

  // Interval in days for the current mode (used for the next-date preview).
  // `?? 1` is a harmless fallback — the off case never reaches here (the preview
  // is gated on _mode != off) and custom is shown only with a valid interval.
  int get _everyDays => switch (_mode) {
    _RecMode.daily => 1,
    _RecMode.weekly => 7,
    _RecMode.custom => _intervalDays ?? 1,
    _RecMode.off => 1,
  };

  void _emit() {
    if (_mode == _RecMode.off) {
      widget.onChanged(null, true);
      return;
    }
    if (_intervalInvalid || _countInvalid) {
      widget.onChanged(null, false);
      return;
    }
    // Inputs are validated above, so the `?? ` fallbacks are never taken.
    final remaining = _limited ? (_repeats ?? 1) : null;
    widget.onChanged(
      Recurrence(everyDays: _everyDays, remaining: remaining),
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(
            t.entry.recurrence_label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SegmentedButton<_RecMode>(
          segments: [
            ButtonSegment(value: _RecMode.off, label: Text(t.entry.recurrence_off)),
            ButtonSegment(
              value: _RecMode.daily,
              label: Text(t.entry.recurrence_daily),
            ),
            ButtonSegment(
              value: _RecMode.weekly,
              label: Text(t.entry.recurrence_weekly),
            ),
            ButtonSegment(
              value: _RecMode.custom,
              label: Text(t.entry.recurrence_custom),
            ),
          ],
          selected: {_mode},
          showSelectedIcon: false,
          onSelectionChanged: (s) {
            setState(() => _mode = s.first);
            _emit();
          },
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        if (_mode == _RecMode.custom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Text(t.entry.recurrence_interval_label),
              const SizedBox(width: 10),
              SizedBox(
                width: _kNumberFieldWidth,
                child: TextField(
                  controller: _interval,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(_emit),
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
              const SizedBox(width: 10),
              Text(t.entry.recurrence_days_unit),
            ],
          ),
          if (_intervalInvalid)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                t.entry.recurrence_invalid_number,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
        if (_mode != _RecMode.off) ...[
          const SizedBox(height: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _limited,
            onChanged: (v) {
              setState(() => _limited = v ?? false);
              _emit();
            },
            title: Text(t.entry.recurrence_repeat_count),
          ),
          if (_limited)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: _kNumberFieldWidth,
                        child: TextField(
                          controller: _count,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (_) => setState(_emit),
                          decoration: const InputDecoration(isDense: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(t.entry.recurrence_times_unit),
                    ],
                  ),
                  if (_countInvalid)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        t.entry.recurrence_invalid_number,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Text(
              t.entry.recurrence_repeat_count_hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
        if (_mode != _RecMode.off && !_intervalInvalid && !_countInvalid) ...[
          const SizedBox(height: 8),
          Text(
            t.entry.recurrence_next_preview(
              date: formatDmy(nextOccurrenceDate(widget.anchorDate, _everyDays)),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
    );
  }
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
