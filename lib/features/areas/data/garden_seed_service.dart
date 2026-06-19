import '../../../core/area_type.dart';
import '../../../core/database/app_database.dart';
import '../../../core/local_prefs/local_prefs.dart';
import 'areas_repository.dart';

/// Seeds the default whole-garden area ("Vrt") exactly once per device (FR-9).
/// Runs at startup for guests (owner `local`) and signed-in users alike — the
/// area then claims/syncs like any other. The seeded flag lives in local prefs,
/// not the area table, so deleting the garden sticks: we never re-create it.
class GardenSeedService {
  GardenSeedService(this._db, this._areas, this._prefs);

  final AppDatabase _db;
  final AreasRepository _areas;
  final LocalPrefsRepository _prefs;

  /// Creates the default garden for [userId] named [name] (already localized by
  /// the caller) unless it was seeded before. The area insert and the "seeded"
  /// flag are written in one transaction, so a crash between them can never
  /// leave an orphan garden with the flag unset (which would double-seed).
  Future<void> seedDefaultIfNeeded({
    required String userId,
    required String name,
  }) async {
    if (await _prefs.defaultGardenSeeded()) return;
    await _db.transaction(() async {
      await _areas.create(userId: userId, name: name, type: AreaType.garden);
      await _prefs.setDefaultGardenSeeded();
    });
  }
}
