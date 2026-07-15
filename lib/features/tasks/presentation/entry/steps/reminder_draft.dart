import 'package:flutter/material.dart' show TimeOfDay;

import '../../../../../core/config.dart';
import '../../../task_specs.dart';

/// Unit for a custom offset. Days make it day-based (fires N whole days before
/// at a chosen time); minutes/hours stay relative to the task's own time.
enum ReminderUnit { minutes, hours, days }

int reminderUnitMinutes(ReminderUnit u) => switch (u) {
  ReminderUnit.minutes => 1,
  ReminderUnit.hours => 60,
  ReminderUnit.days => kMinutesPerDay,
};

/// The editable state of the reminder edit sheet as a pure value: which offset
/// is being built (a preset, or a custom value + unit) and a time of day. All
/// the sheet's decisions — the scheduled offset, whether it carries a time,
/// what spec it produces and whether it may be added — live here so they can be
/// tested without pumping the sheet.
class ReminderDraft {
  const ReminderDraft({
    required this.custom,
    required this.offset,
    required this.customUnit,
    required this.customValue,
    required this.time,
  });

  /// True when the "Po meri…" row is active; then [customUnit]/[customValue]
  /// drive the offset instead of [offset].
  final bool custom;
  final int offset;
  final ReminderUnit customUnit;
  final int customValue;
  final TimeOfDay time;

  /// The offset actually scheduled — a preset, or the custom value in minutes.
  int get effectiveOffset =>
      custom ? customValue * reminderUnitMinutes(customUnit) : offset;

  /// Day-based offsets carry a time of day. For custom offsets the unit decides
  /// (days = day-based); minutes/hours never hit the day-rounding path.
  bool get isDayBased =>
      custom ? customUnit == ReminderUnit.days : offset >= kMinutesPerDay;

  String get timeText =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  /// The time stored on the spec — only day-based reminders carry one.
  String? get specTime => isDayBased ? timeText : null;

  ReminderSpec toSpec() =>
      ReminderSpec(offsetMinutes: effectiveOffset, time: specTime);

  /// The add button is enabled only for a valid, non-duplicate reminder: a
  /// custom offset needs a value >= 1, and the resulting (offset, time) must
  /// not already be in [existing].
  bool canAdd(List<ReminderSpec> existing) =>
      !(custom && customValue < 1) &&
      !_isTaken(existing, effectiveOffset, specTime);
}

/// An exact duplicate of an already-added reminder (same offset and time).
bool _isTaken(List<ReminderSpec> existing, int offset, String? time) =>
    existing.any((r) => r.offsetMinutes == offset && r.time == time);

/// Whether a preset radio row should be disabled. A non-day-based offset has no
/// time, so once added it can only repeat — disable it. Day-based offsets vary
/// by time, so they stay selectable.
bool reminderOffsetTaken(List<ReminderSpec> existing, int offset) =>
    offset < kMinutesPerDay && _isTaken(existing, offset, null);
