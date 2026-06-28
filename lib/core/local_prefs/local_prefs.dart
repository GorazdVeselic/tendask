import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

part 'local_prefs.g.dart';

const _kOnboardingSeen = 'onboarding_seen';
const _kDefaultGardenSeeded = 'default_garden_seeded';
const _kDefaultGardenLocalId = 'default_garden_local_id';
const _kThemeMode = 'theme_mode';
const _kThemePalette = 'theme_palette';
const _kPendingSignInEmail = 'pending_sign_in_email';

/// Device-local "seen once" flags backed by the local_flag table. Never synced —
/// these are per-device UI state (which intro/priming screens the user passed).
class LocalPrefsRepository {
  LocalPrefsRepository(this._db);

  final AppDatabase _db;

  Future<bool> _getFlag(String key) async {
    final row = await (_db.select(
      _db.localFlags,
    )..where((f) => f.key.equals(key))).getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> _setFlag(String key, bool value) => _db
      .into(_db.localFlags)
      .insertOnConflictUpdate(
        LocalFlagsCompanion.insert(key: key, value: '$value'),
      );

  Future<String?> _getString(String key) async {
    final row = await (_db.select(
      _db.localFlags,
    )..where((f) => f.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _setString(String key, String value) => _db
      .into(_db.localFlags)
      .insertOnConflictUpdate(
        LocalFlagsCompanion.insert(key: key, value: value),
      );

  Future<void> _clear(String key) =>
      (_db.delete(_db.localFlags)..where((f) => f.key.equals(key))).go();

  /// The user's chosen theme mode ('system' | 'light' | 'dark'), or null if the
  /// user never changed it (defaults to following the system).
  Future<String?> themeMode() => _getString(_kThemeMode);

  Future<void> setThemeMode(String mode) => _setString(_kThemeMode, mode);

  /// The user's chosen colour palette id ('green' | 'lavender' | …), or null if
  /// the user never changed it (defaults to the green brand palette).
  Future<String?> themePalette() => _getString(_kThemePalette);

  Future<void> setThemePalette(String id) => _setString(_kThemePalette, id);

  /// Whether the user has already passed the onboarding intro (M7.2).
  Future<bool> onboardingSeen() => _getFlag(_kOnboardingSeen);

  Future<void> setOnboardingSeen() => _setFlag(_kOnboardingSeen, true);

  /// Whether this device has already seeded its one-shot default "garden" area
  /// (FR-9). Device-local so a deletion sticks within an install; the *account*
  /// guard that survives reinstall is profile.default_garden_seeded (synced).
  Future<bool> defaultGardenSeeded() => _getFlag(_kDefaultGardenSeeded);

  Future<void> setDefaultGardenSeeded() => _setFlag(_kDefaultGardenSeeded, true);

  /// Id of the locally-seeded default garden while it still awaits reconcile
  /// (it stays owned by `local` so push never uploads it). On sign-in the
  /// reconcile either adopts it (new account) or hard-deletes it (the account
  /// already has its default — drop the duplicate before it ever syncs), then
  /// clears this. Null once reconciled or for a never-seeded device.
  Future<String?> defaultGardenLocalId() => _getString(_kDefaultGardenLocalId);

  Future<void> setDefaultGardenLocalId(String id) =>
      _setString(_kDefaultGardenLocalId, id);

  Future<void> clearDefaultGardenLocalId() => _clear(_kDefaultGardenLocalId);

  /// Email of an in-progress email OTP sign-in (code sent, not yet verified).
  /// Set when the code is dispatched so a relaunch during the wait resumes on
  /// the code step instead of silently dropping the user into guest mode.
  /// Consumed once at launch (an abandoned attempt then falls back to home).
  Future<String?> pendingSignInEmail() => _getString(_kPendingSignInEmail);

  Future<void> setPendingSignInEmail(String email) =>
      _setString(_kPendingSignInEmail, email);

  Future<void> clearPendingSignInEmail() => _clear(_kPendingSignInEmail);
}

@riverpod
LocalPrefsRepository localPrefs(Ref ref) =>
    LocalPrefsRepository(ref.watch(databaseProvider));
