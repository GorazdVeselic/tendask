import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

class ProfileRepository {
  ProfileRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;

  // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
  static const _localUserId = 'local';

  /// Stored UI language code ('sl'/'en'/'de'), or null if never chosen.
  Future<String?> getLang() async {
    final row = await (_db.select(_db.profiles)
          ..where((p) => p.userId.equals(_localUserId)))
        .getSingleOrNull();
    return row?.lang;
  }

  Future<void> setLang(String lang) async {
    final exists = await (_db.select(_db.profiles)
          ..where((p) => p.userId.equals(_localUserId)))
        .getSingleOrNull();
    final now = _clock.now();
    if (exists == null) {
      await _db.into(_db.profiles).insert(ProfilesCompanion.insert(
            userId: _localUserId,
            lang: Value(lang),
            updatedAt: now,
            syncStatus: const Value(kSyncPending),
          ));
    } else {
      // Update only lang — never clobber future h3* cells (M7).
      await (_db.update(_db.profiles)
            ..where((p) => p.userId.equals(_localUserId)))
          .write(ProfilesCompanion(
        lang: Value(lang),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ));
    }
  }
}
