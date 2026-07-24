import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/journal/presentation/journal_entry.dart';
import 'package:tendask/features/journal/presentation/journal_timeline.dart';
import 'package:tendask/i18n/translations.g.dart';

Task _task(String id, DateTime date) => Task(
  id: id,
  userId: 'u1',
  taskTypeId: 'water',
  date: date,
  status: TaskStatus.done,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

Note _note(String id, DateTime date) => Note(
  id: id,
  userId: 'u1',
  content: 'note $id',
  date: date,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  final now = DateTime(2026, 6, 10, 9);

  group('journalEntries', () {
    final tasks = [_task('t1', DateTime(2026, 6, 10, 8))];
    final notes = [_note('n1', DateTime(2026, 6, 10, 12))];

    test('all: tasks and notes mixed, newest first', () {
      final entries = journalEntries(
        tasks: tasks,
        notes: notes,
        filter: JournalFilter.all,
      );

      expect(entries, hasLength(2));
      expect((entries.first as NoteJournalEntry).note.id, 'n1'); // 12:00
      expect((entries.last as TaskJournalEntry).task.id, 't1'); // 08:00
    });

    test('tasks filter drops notes', () {
      final entries = journalEntries(
        tasks: tasks,
        notes: notes,
        filter: JournalFilter.tasks,
      );

      expect(entries.whereType<NoteJournalEntry>(), isEmpty);
      expect(entries, hasLength(1));
    });

    test('notes filter drops tasks', () {
      final entries = journalEntries(
        tasks: tasks,
        notes: notes,
        filter: JournalFilter.notes,
      );

      expect(entries.whereType<TaskJournalEntry>(), isEmpty);
      expect(entries, hasLength(1));
    });

    test('nothing logged yields no entries', () {
      expect(
        journalEntries(tasks: const [], notes: const [], filter: JournalFilter.all),
        isEmpty,
      );
    });
  });

  group('groupEntriesByDay', () {
    test('entries of one day land in one group', () {
      final days = groupEntriesByDay(
        journalEntries(
          tasks: [_task('t1', DateTime(2026, 6, 10, 8))],
          notes: [_note('n1', DateTime(2026, 6, 10, 20))],
          filter: JournalFilter.all,
        ),
      );

      expect(days, hasLength(1));
      expect(days.single.date, DateTime(2026, 6, 10));
      expect(days.single.entries, hasLength(2));
    });

    test('days keep the timeline order — newest day first', () {
      final days = groupEntriesByDay(
        journalEntries(
          tasks: [
            _task('old', DateTime(2026, 6, 8, 10)),
            _task('new', DateTime(2026, 6, 10, 10)),
          ],
          notes: const [],
          filter: JournalFilter.all,
        ),
      );

      expect(days.map((d) => d.date), [
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 8),
      ]);
    });

    test('late evening and early morning of the same day stay together', () {
      final days = groupEntriesByDay(
        journalEntries(
          tasks: [
            _task('late', DateTime(2026, 6, 10, 23, 30)),
            _task('early', DateTime(2026, 6, 10, 0, 15)),
          ],
          notes: const [],
          filter: JournalFilter.all,
        ),
      );

      expect(days, hasLength(1));
      expect(days.single.entries, hasLength(2));
    });
  });

  group('journalEmptyMessage', () {
    test('each filter explains its own emptiness', () {
      expect(journalEmptyMessage(JournalFilter.all, t), t.journal.empty);
      expect(journalEmptyMessage(JournalFilter.tasks, t), t.journal.empty_tasks);
      expect(journalEmptyMessage(JournalFilter.notes, t), t.journal.empty_notes);
    });
  });

  group('journalDayLabel', () {
    test('today and yesterday read as words', () {
      expect(journalDayLabel(DateTime(2026, 6, 10, 23), now, t), t.common.today);
      expect(
        journalDayLabel(DateTime(2026, 6, 9, 1), now, t),
        t.common.yesterday,
      );
    });

    test('older days read as a full date', () {
      expect(journalDayLabel(DateTime(2026, 6, 1), now, t), '1. 6. 2026');
    });

    test('a note dated ahead reads as its date, not as today', () {
      expect(journalDayLabel(DateTime(2026, 6, 20), now, t), '20. 6. 2026');
    });
  });
}
