import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import 'plant_spec.dart';

class UserPlantsRepository {
  UserPlantsRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<List<UserPlant>> watchByArea(String areaId) => (
        _db.select(_db.userPlants)
          ..where((p) => p.deleted.equals(false) & p.areaId.equals(areaId))
          ..orderBy([(p) => OrderingTerm.asc(p.id)])
      ).watch();

  /// Every non-deleted plant — for resolving plant labels across the app.
  Stream<List<UserPlant>> watchAll() => (
        _db.select(_db.userPlants)..where((p) => p.deleted.equals(false))
      ).watch();

  Future<List<UserPlant>> byArea(String areaId) => (
        _db.select(_db.userPlants)
          ..where((p) => p.deleted.equals(false) & p.areaId.equals(areaId))
      ).get();

  Future<UserPlant?> byId(String id) => (
        _db.select(_db.userPlants)..where((p) => p.id.equals(id))
      ).getSingleOrNull();

  Stream<UserPlant?> watchById(String id) => (
        _db.select(_db.userPlants)..where((p) => p.id.equals(id))
      ).watchSingleOrNull();

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
    await _db.into(_db.userPlants).insert(UserPlantsCompanion.insert(
          id: id,
          userId: userId,
          areaId: Value(areaId),
          plantId: Value(plantId),
          customName: Value(customName),
          personalAlias: Value(personalAlias),
          isCustom: Value(plantId == null),
          updatedAt: _clock.now(),
        ));
    return id;
  }

  /// Creates one plant for a specific area (task-form picker flow).
  Future<String> createForArea({
    required String userId,
    required String areaId,
    String? plantId,
    String? customName,
    String? personalAlias,
  }) =>
      create(
        userId: userId,
        areaId: areaId,
        plantId: plantId,
        customName: customName,
        personalAlias: personalAlias,
      );

  /// Reconciles an area's plants with [specs] in a single transaction:
  /// inserts specs without an id, soft-deletes existing rows no longer present.
  Future<void> syncForArea({
    required String userId,
    required String areaId,
    required List<PlantSpec> specs,
  }) async {
    await _db.transaction(() async {
      final existing = await byArea(areaId);
      final keepIds =
          specs.map((s) => s.userPlantId).whereType<String>().toSet();

      for (final row in existing) {
        if (!keepIds.contains(row.id)) {
          await _softDelete(row.id);
        }
      }
      for (final spec in specs.where((s) => s.userPlantId == null)) {
        await createForArea(
          userId: userId,
          areaId: areaId,
          plantId: spec.plantId,
          customName: spec.customName,
          personalAlias: spec.personalAlias,
        );
      }
    });
  }

  Future<void> _softDelete(String id) async {
    await (_db.update(_db.userPlants)..where((p) => p.id.equals(id))).write(
      UserPlantsCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
