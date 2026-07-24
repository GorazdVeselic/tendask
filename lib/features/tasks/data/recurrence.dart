import 'dart:convert';

/// A task recurrence rule, stored as JSON in `task.recurrence` (null = one-off).
///
/// MVP model: every occurrence is `everyDays` apart, anchored on the scheduled
/// date. [remaining] counts how many instances still follow *this* one; null is
/// open-ended. The invariant `recurrence != null ⇔ one more will follow` is kept
/// by [next] returning null for the terminal child (see FR-5 spec §3, D2).
class Recurrence {
  const Recurrence({required this.everyDays, this.remaining})
    : assert(everyDays >= 1, 'everyDays must be >= 1'),
      assert(remaining == null || remaining >= 1, 'remaining must be null or >= 1');

  /// Interval in days (Daily = 1, Weekly = 7, custom = N).
  final int everyDays;

  /// How many instances follow this one; null = open-ended. Never stored as 0.
  final int? remaining;

  /// Tolerant parse: invalid / empty / legacy values become null (one-off).
  /// Never throws — a malformed rule degrades to "no recurrence".
  static Recurrence? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    final everyDays = (decoded['everyDays'] as num?)?.toInt();
    if (everyDays == null || everyDays < 1) return null;
    final rawRemaining = (decoded['remaining'] as num?)?.toInt();
    // A leaked/invalid remaining (< 1) means "open-ended" — keep the rhythm.
    final remaining = (rawRemaining != null && rawRemaining >= 1)
        ? rawRemaining
        : null;
    return Recurrence(everyDays: everyDays, remaining: remaining);
  }

  /// JSON for the repository. Omits `remaining` when open-ended.
  String encode() => jsonEncode({
    'everyDays': everyDays,
    if (remaining != null) 'remaining': remaining,
  });

  /// The recurrence the *next* (materialized) instance should carry, or null if
  /// that instance is the last in the series. The caller still spawns the child
  /// whenever the current rule is non-null — null here only sets the child's own
  /// recurrence to null (D2: the last instance shows no "repeats" badge).
  Recurrence? next() {
    final r = remaining;
    if (r == null) return this; // open-ended: child keeps repeating
    if (r > 1) return Recurrence(everyDays: everyDays, remaining: r - 1);
    return null; // remaining == 1: the child is the terminal instance
  }

  @override
  bool operator ==(Object other) =>
      other is Recurrence &&
      other.everyDays == everyDays &&
      other.remaining == remaining;

  @override
  int get hashCode => Object.hash(everyDays, remaining);
}

/// Next occurrence date, anchored on the *scheduled* date (not completion).
/// Civil-day field arithmetic keeps the wall-clock time across DST. Pure: takes
/// no Clock, since the anchor is the task's own date, not "now".
DateTime nextOccurrenceDate(DateTime scheduledLocal, int everyDays) => DateTime(
  scheduledLocal.year,
  scheduledLocal.month,
  scheduledLocal.day + everyDays,
  scheduledLocal.hour,
  scheduledLocal.minute,
);
