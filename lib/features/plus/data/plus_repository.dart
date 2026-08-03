import '../../../core/database/app_database.dart';

/// Server-owned Tendask+ columns of a profile row (FR-20 §7). The client only
/// ever pulls these — see `remote_mappers.dart`, which never pushes them.
class PlusRecord {
  const PlusRecord({this.until, this.token, this.kind});

  /// Mirror of the signed claim, kept for display only: eligibility is decided
  /// by the token, so a hand-edited column buys nothing.
  final DateTime? until;
  final String? token;
  final String? kind;
}

class PlusRepository {
  PlusRepository(this._db);

  final AppDatabase _db;

  /// Tendask+ columns for [userId]; null while the profile row is missing
  /// (a guest that has never synced).
  Stream<PlusRecord?> watch(String userId) =>
      (_db.select(_db.profiles)..where((p) => p.userId.equals(userId)))
          .watchSingleOrNull()
          .map(
            (row) => row == null
                ? null
                : PlusRecord(
                    until: row.plusUntil,
                    token: row.plusToken,
                    kind: row.plusKind,
                  ),
          );
}
