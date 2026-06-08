import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

class NotesRepository {
  NotesRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  /// All notes newest first — for the garden journal (03).
  Stream<List<Note>> watchAll() =>
      (_db.select(_db.notes)
            ..where((n) => n.deleted.equals(false))
            ..orderBy([(n) => OrderingTerm.desc(n.date)]))
          .watch();

  Future<Note?> byId(String id) =>
      (_db.select(_db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<String> create({
    required String userId,
    required DateTime date,
    required String content,
    String? areaId,
    String? userPlantId,
  }) async {
    final id = _uuid.v4();
    await _db
        .into(_db.notes)
        .insert(
          NotesCompanion.insert(
            id: id,
            userId: userId,
            date: date.toUtc(),
            content: content,
            areaId: Value(areaId),
            userPlantId: Value(userPlantId),
            updatedAt: _clock.now(),
          ),
        );
    return id;
  }

  Future<void> updateNote({
    required String id,
    required DateTime date,
    required String content,
    String? areaId,
    String? userPlantId,
  }) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        date: Value(date.toUtc()),
        content: Value(content),
        areaId: Value(areaId),
        userPlantId: Value(userPlantId),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }
}
