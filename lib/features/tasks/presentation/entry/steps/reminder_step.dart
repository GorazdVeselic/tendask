import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/auth/auth_service.dart';
import '../../../../../core/config.dart';
import '../../../../../core/notifications/notification_service.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/section_label.dart';
import '../../../../../core/widgets/sheet_handle.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../../notifications/presentation/notification_priming_sheet.dart';
import '../../../../settings/application/profile_providers.dart';
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
/// Adding a reminder first ensures the OS permissions it needs (notifications +
/// exact alarms) — without them a scheduled reminder would never fire.
class ReminderStepBody extends ConsumerWidget {
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

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final notif = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Priming screen (21) before the OS dialog, the first time around — skip it
    // once notifications are already granted.
    if (!await notif.areNotificationsEnabled()) {
      if (!context.mounted) return;
      if (await showNotificationPriming(context) != true) return;
    }
    // Notifications permission (Android 13+), requested in context on intent.
    if (!await notif.requestPermission()) {
      messenger.showSnackBar(SnackBar(content: Text(t.entry.rem_perm_denied)));
      return;
    }
    // Exact alarms are granted only via system settings (not a dialog), so we
    // explain and send the user there; they re-tap + after enabling.
    if (!await notif.canScheduleExactAlarms()) {
      if (!context.mounted) return;
      final open = await showConfirmDialog(
        context,
        title: t.entry.rem_exact_title,
        body: t.entry.rem_exact_body,
        confirmLabel: t.entry.rem_exact_open,
        cancelLabel: t.tasks_list.delete_cancel,
        destructive: false,
      );
      if (open) await notif.openExactAlarmSettings();
      return;
    }
    final userId = ref.read(authServiceProvider).userId;
    final settings = await ref
        .read(profileRepositoryProvider)
        .notificationSettings(userId);
    if (!context.mounted) return;
    final spec = await showReminderEditSheet(
      context,
      taskDate,
      reminders,
      initialOffset: settings.defaultReminderOffset,
    );
    if (!context.mounted) return;
    if (spec != null) onAdd(spec);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: Text(
                    t.entry.reminder_why,
                    style: theme.textTheme.bodySmall,
                  ),
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
                  title: Text(
                    reminderLabel(reminders[i], t),
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => onRemove(i),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _add(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t.entry.reminder_add),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t.entry.reminder_note,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Edit sheet ──────────────────────────────────────────────────────────────

Future<ReminderSpec?> showReminderEditSheet(
  BuildContext context,
  DateTime taskDate,
  List<ReminderSpec> existing, {
  required int initialOffset,
}) {
  return showModalBottomSheet<ReminderSpec>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReminderEditSheet(
      taskDate: taskDate,
      existing: existing,
      initialOffset: initialOffset,
    ),
  );
}

/// Offset presets in minutes; day-based offsets (>= 1440) carry a time of day.
const _offsets = [0, 10, 60, 1440, 2880];

/// Sentinel radio value for the "custom offset" row.
const _kCustomOffset = -1;

/// Unit for a custom offset. Days make it day-based (fires N whole days before
/// at a chosen time); minutes/hours stay relative to the task's own time.
enum _CustomUnit { minutes, hours, days }

int _unitMinutes(_CustomUnit u) => switch (u) {
  _CustomUnit.minutes => 1,
  _CustomUnit.hours => 60,
  _CustomUnit.days => 1440,
};

class _ReminderEditSheet extends StatefulWidget {
  const _ReminderEditSheet({
    required this.taskDate,
    required this.existing,
    required this.initialOffset,
  });
  final DateTime taskDate;
  final List<ReminderSpec> existing;
  final int initialOffset;

  @override
  State<_ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends State<_ReminderEditSheet> {
  late int _offset = _offsets.contains(widget.initialOffset)
      ? widget.initialOffset
      : kDefaultReminderOffset;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);

  // Custom offset (the "Po meri…" row): value + unit, edited inline.
  bool _custom = false;
  _CustomUnit _customUnit = _CustomUnit.days;
  final _customCtrl = TextEditingController(text: '2');
  int get _customValue => int.tryParse(_customCtrl.text) ?? 0;

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  /// The offset actually scheduled — a preset, or the custom value in minutes.
  int get _effectiveOffset =>
      _custom ? _customValue * _unitMinutes(_customUnit) : _offset;

  /// Day-based offsets carry a time of day. For custom offsets the unit decides
  /// (days = day-based), so minutes/hours never hit the day-rounding path.
  bool get _isDayBased =>
      _custom ? _customUnit == _CustomUnit.days : _offset >= 1440;

  /// An exact duplicate of an already-added reminder (same offset and time).
  bool _isTaken(int offset, String? time) =>
      widget.existing.any((r) => r.offsetMinutes == offset && r.time == time);

  /// A non-day-based offset has no time, so once added it can only repeat —
  /// disable it. Day-based offsets vary by time, so they stay selectable.
  bool _offsetTaken(int offset) => offset < 1440 && _isTaken(offset, null);

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

  String _unitLabel(Translations t) => switch (_customUnit) {
    _CustomUnit.minutes => t.entry.rem_unit_min,
    _CustomUnit.hours => t.entry.rem_unit_hour,
    _CustomUnit.days => t.entry.rem_unit_day,
  };

  /// Human preview of the reminder being built, e.g. "2 dni prej ob 18:00".
  String _preview(Translations t) {
    final base = _custom
        ? '$_customValue ${_unitLabel(t)} ${t.entry.rem_before}'
        : _label(_offset, t);
    return _isDayBased ? '$base ${t.entry.rem_at(t: _timeText)}' : base;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _confirm() {
    Navigator.of(context).pop(
      ReminderSpec(
        offsetMinutes: _effectiveOffset,
        time: _isDayBased ? _timeText : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Padding(
      // Lift the sheet above the keyboard so the number field stays visible.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              Text(
                t.entry.reminder_title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<int>(
                groupValue: _custom ? _kCustomOffset : _offset,
                onChanged: (v) => setState(() {
                  if (v == _kCustomOffset) {
                    _custom = true;
                  } else if (v != null) {
                    _custom = false;
                    _offset = v;
                  }
                }),
                child: Column(
                  children: [
                    for (final offset in _offsets)
                      RadioListTile<int>(
                        value: offset,
                        enabled: !_offsetTaken(offset),
                        title: Text(_label(offset, t)),
                        subtitle: _offsetTaken(offset)
                            ? Text(
                                t.entry.rem_added,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              )
                            : null,
                        secondary: const Text(
                          '🔔',
                          style: TextStyle(fontSize: 16),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    RadioListTile<int>(
                      value: _kCustomOffset,
                      title: Text(t.entry.rem_custom),
                      secondary: const Text(
                        '🔔',
                        style: TextStyle(fontSize: 16),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              if (_custom) ...[
                const Divider(),
                FieldLabel(t.entry.rem_custom_label),
                Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: TextField(
                        controller: _customCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<_CustomUnit>(
                        segments: [
                          ButtonSegment(
                            value: _CustomUnit.minutes,
                            label: Text(t.entry.rem_unit_min),
                          ),
                          ButtonSegment(
                            value: _CustomUnit.hours,
                            label: Text(t.entry.rem_unit_hour),
                          ),
                          ButtonSegment(
                            value: _CustomUnit.days,
                            label: Text(t.entry.rem_unit_day),
                          ),
                        ],
                        selected: {_customUnit},
                        onSelectionChanged: (s) =>
                            setState(() => _customUnit = s.first),
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                Text(
                  t.entry.rem_time_note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Live preview of the reminder being built (presets and custom).
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('🔔', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _preview(t),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  // Day-based offsets stay selectable but a same-time pick would
                  // duplicate — block the add then. Custom needs a value >= 1.
                  onPressed:
                      (_custom && _customValue < 1) ||
                          _isTaken(
                            _effectiveOffset,
                            _isDayBased ? _timeText : null,
                          )
                      ? null
                      : _confirm,
                  child: Text(t.entry.reminder_add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
