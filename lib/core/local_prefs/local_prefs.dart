import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

part 'local_prefs.g.dart';

const _kOnboardingSeen = 'onboarding_seen';
const _kDefaultGardenSeeded = 'default_garden_seeded';
const _kThemeMode = 'theme_mode';
const _kThemePalette = 'theme_palette';

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

  /// Whether the default "garden" area has already been seeded once (FR-9).
  /// Device-local so deletion sticks: we seed exactly once, never "if missing"
  /// (which would resurrect a garden the user deleted on the next launch).
  Future<bool> defaultGardenSeeded() => _getFlag(_kDefaultGardenSeeded);

  Future<void> setDefaultGardenSeeded() =>
      _setFlag(_kDefaultGardenSeeded, true);
}

@riverpod
LocalPrefsRepository localPrefs(Ref ref) =>
    LocalPrefsRepository(ref.watch(databaseProvider));
