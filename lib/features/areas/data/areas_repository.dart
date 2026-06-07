import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/area_type.dart';
import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

class AreasRepository {
  AreasRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<List<Area>> watchAll() => (
        _db.select(_db.areas)
          ..where((a) => a.deleted.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.name)])
      ).watch();

  Stream<Area?> watchById(String id) =>
      (_db.select(_db.areas)..where((a) => a.id.equals(id)))
          .watchSingleOrNull();

  Future<Area?> byId(String id) =>
      (_db.select(_db.areas)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<String> create({
    required String userId,
    required String name,
    required AreaType type,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.areas).insert(AreasCompanion.insert(
          id: id,
          userId: userId,
          name: name,
          type: Value(type),
          updatedAt: _clock.now(),
        ));
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    required AreaType type,
  }) async {
    await (_db.update(_db.areas)..where((a) => a.id.equals(id))).write(
      AreasCompanion(
        name: Value(name),
        type: Value(type),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    await _db.transaction(() async {
      // Re-parent this area's plants to "no area" so they resurface under
      // "Brez območja" instead of pointing at a deleted area (which would hide
      // them from the garden entirely). Atomic with the area tombstone.
      await (_db.update(_db.userPlants)..where((p) => p.areaId.equals(id)))
          .write(UserPlantsCompanion(
        areaId: const Value(null),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ));
      await (_db.update(_db.areas)..where((a) => a.id.equals(id))).write(
        AreasCompanion(
          deleted: const Value(true),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value(kSyncPending),
        ),
      );
    });
  }
}
