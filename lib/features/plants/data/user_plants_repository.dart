import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

/// Outcome of [UserPlantsRepository.moveToArea] — a move is refused when the
/// destination area already holds that species (the (area, species) pair is
/// kept unique).
enum PlantMoveResult { moved, duplicate }

class UserPlantsRepository {
  UserPlantsRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<List<UserPlant>> watchByArea(String areaId) =>
      (_db.select(_db.userPlants)
            ..where((p) => p.deleted.equals(false) & p.areaId.equals(areaId))
            ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]))
          .watch();

  /// Distinct catalog species the user has used, newest first — feeds the
  /// "Frequent" row of the plant-add screen. Custom (plantId == null) entries
  /// are excluded; one query, grouped + bounded (no full scan).
  Future<List<String>> recentPlantIds({int limit = kRecentPlantsLimit}) async {
    final pid = _db.userPlants.plantId;
    final maxUpdated = _db.userPlants.updatedAt.max();
    final rows =
        await (_db.selectOnly(_db.userPlants)
              ..addColumns([pid, maxUpdated])
              ..where(_db.userPlants.deleted.equals(false) & pid.isNotNull())
              ..groupBy([pid])
              ..orderBy([OrderingTerm.desc(maxUpdated)])
              ..limit(limit))
            .get();
    // Non-null: rows are filtered by pid.isNotNull() above.
    return [for (final r in rows) r.read(pid)!];
  }

  /// Every non-deleted plant — for resolving plant labels across the app.
  Stream<List<UserPlant>> watchAll() => (_db.select(
    _db.userPlants,
  )..where((p) => p.deleted.equals(false))).watch();

  Future<List<UserPlant>> byArea(String areaId) => (_db.select(
    _db.userPlants,
  )..where((p) => p.deleted.equals(false) & p.areaId.equals(areaId))).get();

  Future<UserPlant?> byId(String id) => (_db.select(
    _db.userPlants,
  )..where((p) => p.id.equals(id))).getSingleOrNull();

  Stream<UserPlant?> watchById(String id) => (_db.select(
    _db.userPlants,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();

  /// Creates one plant and returns its id. Area is optional (e.g. a plant added
  /// inline from the subject picker, location assigned later).
  Future<String> create({
    required String userId,
    String? areaId,
    String? plantId,
    String? customName,
    String? personalAlias,
  }) async {
    final id = _uuid.v4();
    await _db
        .into(_db.userPlants)
        .insert(
          UserPlantsCompanion.insert(
            id: id,
            userId: userId,
            areaId: Value(areaId),
            plantId: Value(plantId),
            customName: Value(customName),
            personalAlias: Value(personalAlias),
            isCustom: Value(plantId == null),
            updatedAt: _clock.now(),
          ),
        );
    return id;
  }

  /// Creates one plant for a specific area (task-form picker flow).
  Future<String> createForArea({
    required String userId,
    required String areaId,
    String? plantId,
    String? customName,
    String? personalAlias,
  }) => create(
    userId: userId,
    areaId: areaId,
    plantId: plantId,
    customName: customName,
    personalAlias: personalAlias,
  );

  /// True when a non-deleted instance of [plantId] already lives in [areaId].
  /// Custom plants (null [plantId]) never collide. [excludeId] skips a row
  /// (the instance being moved).
  Future<bool> areaHasSpecies({
    required String? areaId,
    required String? plantId,
    String? excludeId,
  }) async {
    if (plantId == null) return false;
    final rows =
        await (_db.select(_db.userPlants)..where((p) {
              var w = p.deleted.equals(false) & p.plantId.equals(plantId);
              w =
                  w &
                  (areaId == null
                      ? p.areaId.isNull()
                      : p.areaId.equals(areaId));
              if (excludeId != null) w = w & p.id.isNotValue(excludeId);
              return w;
            }))
            .get();
    return rows.isNotEmpty;
  }

  /// Moves a plant to [areaId] (optionally rewriting its alias). Refuses with
  /// [PlantMoveResult.duplicate] when the target area already holds that
  /// species, so an area never ends up with the same plant twice.
  Future<PlantMoveResult> moveToArea({
    required String id,
    String? areaId,
    String? personalAlias,
  }) async {
    final plant = await byId(id);
    if (plant == null) return PlantMoveResult.moved;
    if (areaId != plant.areaId &&
        await areaHasSpecies(
          areaId: areaId,
          plantId: plant.plantId,
          excludeId: id,
        )) {
      return PlantMoveResult.duplicate;
    }
    await update(id: id, areaId: areaId, personalAlias: personalAlias);
    return PlantMoveResult.moved;
  }

  /// Edits one plant instance (alias and/or its area).
  Future<void> update({
    required String id,
    String? areaId,
    String? personalAlias,
  }) async {
    await (_db.update(_db.userPlants)..where((p) => p.id.equals(id))).write(
      UserPlantsCompanion(
        areaId: Value(areaId),
        personalAlias: Value(personalAlias),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  Future<void> softDelete(String id) => _softDelete(id);

  Future<void> _softDelete(String id) async {
    await (_db.update(_db.userPlants)..where((p) => p.id.equals(id))).write(
      UserPlantsCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }
}
