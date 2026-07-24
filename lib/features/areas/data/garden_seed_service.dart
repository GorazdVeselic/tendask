import '../../../core/area_type.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/local_prefs/local_prefs.dart';
import 'areas_repository.dart';

/// Seeds the default whole-garden area ("Vrt") once per device (FR-9). The
/// garden is created owned by [kLocalUserId] and stays that way until the
/// reconcile on sign-in (reconcileDefaultGarden): push never uploads a `local`
/// row, so a guest garden can be adopted (new account) or hard-deleted (the
/// account already has its default) without ever leaving a duplicate in the
/// cloud. The synced profile flag — not this device flag — is the per-account
/// "already seeded" guard that survives a reinstall.
class GardenSeedService {
  GardenSeedService(this._db, this._areas, this._prefs);

  final AppDatabase _db;
  final AreasRepository _areas;
  final LocalPrefsRepository _prefs;

  /// Creates the default garden named [name] (already localized by the caller)
  /// unless this device seeded one before. The area insert, the device "seeded"
  /// flag and the pending-reconcile id are written in one transaction, so a
  /// crash between them can never leave an orphan garden or a dangling id.
  Future<void> seedDefaultIfNeeded({required String name}) async {
    if (await _prefs.defaultGardenSeeded()) return;
    await _db.transaction(() async {
      final id = await _areas.create(
        userId: kLocalUserId,
        name: name,
        type: AreaType.garden,
      );
      await _prefs.setDefaultGardenSeeded();
      await _prefs.setDefaultGardenLocalId(id);
    });
  }
}
