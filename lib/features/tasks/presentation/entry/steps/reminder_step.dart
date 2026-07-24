import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/auth/auth_service.dart';
import '../../../../../core/config.dart';
import '../../../../../core/notifications/notification_service.dart';
import '../../../../../core/widgets/section_label.dart';
import '../../../../../core/widgets/sheet_handle.dart';
import '../../../../../i18n/translations.g.dart';
import '../../../../notifications/application/reminder_schedule.dart';
import '../../../../notifications/presentation/notification_priming_sheet.dart';
import '../../../../notifications/presentation/widgets/reminder_sound_banner.dart';
import '../../../../settings/application/profile_providers.dart';
import '../../../task_specs.dart';
import 'reminder_draft.dart';

/// Base label for a reminder offset, e.g. "1 day before" (without a time of day).
String reminderOffsetLabel(int offsetMinutes, Translations t) =>
    switch (offsetMinutes) {
      0 => t.entry.rem_event,
      10 => t.entry.rem_10min,
      60 => t.entry.rem_1hour,
      1440 => t.entry.rem_1day,
      2880 => t.entry.rem_2day,
      _ => t.entry.rem_event,
    };

/// Human label for a reminder spec, e.g. "1 dan prej ob 18:00".
String reminderLabel(ReminderSpec r, Translations t) {
  final base = reminderOffsetLabel(r.offsetMinutes, t);
  if (r.offsetMinutes >= kMinutesPerDay && r.time != null) {
    return '$base ${t.entry.rem_at(t: r.time!)}';
  }
  return base;
}

/// The default reminder seeded for a planned task (T7), using the user's preferred
/// offset. Day-based offsets carry [kDefaultReminderTime]; if that would fire in
/// the past (a near task), falls back to at-event so a planned task always gets a
/// reminder that actually fires. Pure: [nowLocal] is injected for testability.
ReminderSpec defaultReminderSpec({
  required int offsetMinutes,
  required DateTime taskDateLocal,
  required DateTime nowLocal,
}) {
  final time = offsetMinutes >= kMinutesPerDay ? kDefaultReminderTime : null;
  final fire = reminderFireTime(
    taskDateLocal: taskDateLocal,
    offsetMinutes: offsetMinutes,
    reminderTime: time,
  );
  if (!fire.isAfter(nowLocal)) return const ReminderSpec(offsetMinutes: 0);
  return ReminderSpec(offsetMinutes: offsetMinutes, time: time);
}

/// Step 4 — reminders (notifications). Shown only when the task is waiting.
/// Adding a reminder first ensures the OS permissions it needs (notifications +
/// exact alarms) — without them a scheduled reminder would never fire.
class ReminderStepBody extends ConsumerWidget {
  const ReminderStepBody({
    super.key,
    required this.reminders,
    required this.taskDate,
    required this.seededDefault,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ReminderSpec> reminders;
  final DateTime taskDate;

  /// Whether the list still holds the auto-seeded default reminder (T7) — drives
  /// the hint explaining it was added and can be removed.
  final bool seededDefault;
  final ValueChanged<ReminderSpec> onAdd;
  final ValueChanged<int> onRemove;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final notif = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Priming (21) + notifications + exact-alarm gate, in context on intent.
    // Shared with the save-time seed check so both ask for the same permissions.
    switch (await requestReminderPermissions(context, notif)) {
      case ReminderPermission.primingDeclined:
      case ReminderPermission.exactAlarmMissing:
        return;
      case ReminderPermission.notifDenied:
        messenger.showSnackBar(SnackBar(content: Text(t.entry.rem_perm_denied)));
        return;
      case ReminderPermission.granted:
        break;
    }
    if (!context.mounted) return;
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
        // Shown only when reminders would be silent (volume 0 / silent mode).
        const ReminderSoundBanner(),
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
        if (seededDefault && reminders.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            t.entry.rem_default_hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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

/// Sentinel radio value for the "custom offset" row.
const _kCustomOffset = -1;

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
  late int _offset = kReminderOffsetPresets.contains(widget.initialOffset)
      ? widget.initialOffset
      : kDefaultReminderOffset;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);

  // Custom offset (the "Po meri…" row): value + unit, edited inline.
  bool _custom = false;
  ReminderUnit _customUnit = ReminderUnit.days;
  final _customCtrl = TextEditingController(text: '2');
  int get _customValue => int.tryParse(_customCtrl.text) ?? 0;

  /// The current editable state as a pure value — the source of every decision
  /// (scheduled offset, day-based, spec, add-enabled) below.
  ReminderDraft get _draft => ReminderDraft(
    custom: _custom,
    offset: _offset,
    customUnit: _customUnit,
    customValue: _customValue,
    time: _time,
  );

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  String _unitLabel(Translations t) => switch (_customUnit) {
    ReminderUnit.minutes => t.entry.rem_unit_min,
    ReminderUnit.hours => t.entry.rem_unit_hour,
    ReminderUnit.days => t.entry.rem_unit_day,
  };

  /// Human preview of the reminder being built, e.g. "2 dni prej ob 18:00".
  String _preview(Translations t) {
    final draft = _draft;
    final base = _custom
        ? '$_customValue ${_unitLabel(t)} ${t.entry.rem_before}'
        : reminderOffsetLabel(_offset, t);
    return draft.isDayBased ? '$base ${t.entry.rem_at(t: draft.timeText)}' : base;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _confirm() => Navigator.of(context).pop(_draft.toSpec());

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
                    for (final offset in kReminderOffsetPresets)
                      RadioListTile<int>(
                        value: offset,
                        enabled: !reminderOffsetTaken(widget.existing, offset),
                        title: Text(reminderOffsetLabel(offset, t)),
                        subtitle: reminderOffsetTaken(widget.existing, offset)
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
                      child: SegmentedButton<ReminderUnit>(
                        segments: [
                          ButtonSegment(
                            value: ReminderUnit.minutes,
                            label: Text(t.entry.rem_unit_min),
                          ),
                          ButtonSegment(
                            value: ReminderUnit.hours,
                            label: Text(t.entry.rem_unit_hour),
                          ),
                          ButtonSegment(
                            value: ReminderUnit.days,
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
              if (_draft.isDayBased) ...[
                const Divider(),
                Row(
                  children: [
                    Expanded(child: Text(t.entry.rem_choose_time)),
                    TextButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_outlined, size: 18),
                      label: Text(_draft.timeText),
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
                  onPressed: _draft.canAdd(widget.existing) ? _confirm : null,
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
