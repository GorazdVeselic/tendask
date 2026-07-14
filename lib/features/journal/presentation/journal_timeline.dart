import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import 'journal_entry.dart';

/// Which kinds of entries the timeline shows.
enum JournalFilter { all, tasks, notes }

/// Completed tasks and notes merged into one newest-first timeline.
List<JournalEntry> journalEntries({
  required List<Task> tasks,
  required List<Note> notes,
  required JournalFilter filter,
}) =>
    <JournalEntry>[
      if (filter != JournalFilter.notes)
        for (final task in tasks) TaskJournalEntry(task),
      if (filter != JournalFilter.tasks)
        for (final note in notes) NoteJournalEntry(note),
    ]..sort((a, b) => b.date.compareTo(a.date));

/// A day of the timeline and the entries logged on it.
class JournalDayGroup {
  JournalDayGroup(this.date, this.entries);

  final DateTime date;
  final List<JournalEntry> entries;
}

/// Splits a timeline into local calendar days, keeping the order it came in —
/// so a newest-first timeline yields newest-first days.
List<JournalDayGroup> groupEntriesByDay(List<JournalEntry> entries) {
  final groups = <DateTime, JournalDayGroup>{};

  for (final entry in entries) {
    final day = startOfDay(entry.date.toLocal());
    groups
        .putIfAbsent(day, () => JournalDayGroup(day, []))
        .entries
        .add(entry);
  }
  return groups.values.toList();
}

String journalEmptyMessage(JournalFilter filter, Translations t) =>
    switch (filter) {
      JournalFilter.notes => t.journal.empty_notes,
      JournalFilter.tasks => t.journal.empty_tasks,
      JournalFilter.all => t.journal.empty,
    };

/// Day heading of a timeline group. A note may be dated ahead (the note form
/// allows it), and such a day reads as its date — only the current day is
/// "today".
String journalDayLabel(DateTime date, DateTime now, Translations t) {
  final day = startOfDay(date);
  final today = startOfDay(now);

  if (day == today) return t.common.today;
  if (day == today.subtract(const Duration(days: 1))) return t.common.yesterday;
  return formatDmy(date);
}
