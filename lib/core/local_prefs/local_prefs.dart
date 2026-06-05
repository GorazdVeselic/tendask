import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

part 'local_prefs.g.dart';

const _kOnboardingSeen = 'onboarding_seen';

/// Device-local "seen once" flags backed by the local_flag table. Never synced —
/// these are per-device UI state (which intro/priming screens the user passed).
class LocalPrefsRepository {
  LocalPrefsRepository(this._db);

  final AppDatabase _db;

  Future<bool> _getFlag(String key) async {
    final row = await (_db.select(_db.localFlags)
          ..where((f) => f.key.equals(key)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> _setFlag(String key, bool value) =>
      _db.into(_db.localFlags).insertOnConflictUpdate(
            LocalFlagsCompanion.insert(key: key, value: '$value'),
          );

  /// Whether the user has already passed the onboarding intro (M7.2).
  Future<bool> onboardingSeen() => _getFlag(_kOnboardingSeen);

  Future<void> setOnboardingSeen() => _setFlag(_kOnboardingSeen, true);
}

@riverpod
LocalPrefsRepository localPrefs(Ref ref) =>
    LocalPrefsRepository(ref.watch(databaseProvider));
