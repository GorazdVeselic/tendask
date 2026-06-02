import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/journal/data/notes_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(DateTime now) : _now = now;
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late NotesRepository repo;

  const areaId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const userId = 'user-1';
  final t0 = DateTime.utc(2026, 6, 2, 8);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = _FakeClock(t0);
    repo = NotesRepository(db, clock: clock);

    await db.into(db.areas).insert(AreasCompanion.insert(
          id: areaId,
          userId: userId,
          name: 'Vrt',
          type: const Value(AreaType.bed),
          updatedAt: t0,
        ));
  });

  tearDown(() async => db.close());

  group('NotesRepository.create', () {
    test('stores content, UTC date, defaults and a new UUID', () async {
      final id = await repo.create(
        userId: userId,
        date: t0,
        content: 'Brown spots on tomato leaves',
        areaId: areaId,
      );

      final note = await repo.byId(id);
      expect(note, isNotNull);
      expect(note!.userId, userId);
      expect(note.content, 'Brown spots on tomato leaves');
      expect(note.areaId, areaId);
      expect(note.deleted, false);
      expect(note.syncStatus, 'pending');
      expect(note.date.toUtc(), t0);
      expect(note.updatedAt.toUtc(), t0);
    });

    test('normalizes a local date to UTC', () async {
      final local = DateTime(2026, 6, 2, 10);
      final id = await repo.create(
          userId: userId, date: local, content: 'x');

      final note = await repo.byId(id);
      expect(note!.date.toUtc(), local.toUtc());
    });

    test('two creates produce distinct IDs', () async {
      final id1 = await repo.create(userId: userId, date: t0, content: 'a');
      final id2 = await repo.create(userId: userId, date: t0, content: 'b');
      expect(id1, isNot(id2));
    });
  });

  group('NotesRepository.watchAll', () {
    test('returns non-deleted notes, newest first', () async {
      await repo.create(userId: userId, date: t0, content: 'older');
      final newer = await repo.create(
          userId: userId,
          date: t0.add(const Duration(days: 1)),
          content: 'newer');
      final gone =
          await repo.create(userId: userId, date: t0, content: 'gone');
      await repo.softDelete(gone);

      final notes = await repo.watchAll().first;
      expect(notes.length, 2);
      expect(notes.first.id, newer);
    });
  });

  group('NotesRepository.updateNote', () {
    test('changes content and marks pending', () async {
      final id = await repo.create(userId: userId, date: t0, content: 'old');

      clock.advance(const Duration(minutes: 5));
      await repo.updateNote(id: id, date: t0, content: 'new');

      final note = await repo.byId(id);
      expect(note!.content, 'new');
      expect(note.syncStatus, 'pending');
      expect(note.updatedAt, isNot(t0));
    });
  });

  group('NotesRepository.softDelete', () {
    test('hides the note from watchAll', () async {
      final id = await repo.create(userId: userId, date: t0, content: 'x');

      await repo.softDelete(id);

      final note = await repo.byId(id);
      expect(note!.deleted, true);
      expect(await repo.watchAll().first, isEmpty);
    });
  });
}
