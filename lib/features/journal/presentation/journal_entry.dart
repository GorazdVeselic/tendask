import '../../../core/database/app_database.dart';

/// A single row in the garden journal (03): either a completed task or a
/// standalone note, mixed and sorted by [date].
sealed class JournalEntry {
  const JournalEntry();
  DateTime get date;
}

class TaskJournalEntry extends JournalEntry {
  const TaskJournalEntry(this.task);
  final Task task;

  @override
  DateTime get date => task.date;
}

class NoteJournalEntry extends JournalEntry {
  const NoteJournalEntry(this.note);
  final Note note;

  @override
  DateTime get date => note.date;
}
