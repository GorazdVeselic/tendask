import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/config.dart';
import '../../../../../core/date_format.dart';
import '../../../../../core/widgets/section_label.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../data/recurrence.dart';
import '../steps/when_rules.dart';

/// Width of the small numeric inputs (interval / repeat count).
const double _kNumberFieldWidth = 64;

/// The recurrence sub-form: frequency (off/daily/weekly/custom), a custom
/// interval, and an optional total-occurrences cap. Stateful so the text fields
/// keep their own controllers; emits a [Recurrence] (or null) on every change.
class RecurrencePicker extends StatefulWidget {
  const RecurrencePicker({
    super.key,
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
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late RecurrenceMode _mode;
  late final TextEditingController _interval;
  late bool _limited;
  late final TextEditingController _count;

  @override
  void initState() {
    super.initState();
    final rule = widget.recurrence;
    _mode = recurrenceModeOf(rule);
    // rule is non-null whenever the mode is custom (see recurrenceModeOf).
    _interval = TextEditingController(
      text: _mode == RecurrenceMode.custom
          ? '${rule!.everyDays}'
          : '$kRecurrenceDefaultIntervalDays',
    );
    final remaining = rule?.remaining;
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

  RecurrenceDraft get _draft => evaluateRecurrence(
    mode: _mode,
    intervalText: _interval.text,
    limited: _limited,
    countText: _count.text,
  );

  void _emit() {
    final draft = _draft;
    widget.onChanged(draft.rule, draft.valid);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final draft = _draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(t.entry.recurrence_label),
        SegmentedButton<RecurrenceMode>(
          segments: [
            ButtonSegment(
              value: RecurrenceMode.off,
              label: Text(t.entry.recurrence_off),
            ),
            ButtonSegment(
              value: RecurrenceMode.daily,
              label: Text(t.entry.recurrence_daily),
            ),
            ButtonSegment(
              value: RecurrenceMode.weekly,
              label: Text(t.entry.recurrence_weekly),
            ),
            ButtonSegment(
              value: RecurrenceMode.custom,
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
        if (_mode == RecurrenceMode.custom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Text(t.entry.recurrence_interval_label),
              const SizedBox(width: 10),
              _NumberField(controller: _interval, onChanged: () => setState(_emit)),
              const SizedBox(width: 10),
              Text(t.entry.recurrence_days_unit),
            ],
          ),
          if (draft.intervalInvalid) const _InvalidNumberNote(),
        ],
        if (_mode != RecurrenceMode.off) ...[
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
                      _NumberField(
                        controller: _count,
                        onChanged: () => setState(_emit),
                      ),
                      const SizedBox(width: 10),
                      Text(t.entry.recurrence_times_unit),
                    ],
                  ),
                  if (draft.countInvalid) const _InvalidNumberNote(),
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
        if (_mode != RecurrenceMode.off && draft.valid) ...[
          const SizedBox(height: 8),
          Text(
            t.entry.recurrence_next_preview(
              date: formatDmy(
                nextOccurrenceDate(widget.anchorDate, draft.everyDays),
              ),
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

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _kNumberFieldWidth,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      onChanged: (_) => onChanged(),
      decoration: const InputDecoration(isDense: true),
    ),
  );
}

class _InvalidNumberNote extends StatelessWidget {
  const _InvalidNumberNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        context.t.entry.recurrence_invalid_number,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
