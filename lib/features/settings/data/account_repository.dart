import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';

/// GDPR actions for the account: data export and account deletion.
class AccountRepository {
  AccountRepository(this._db, this._auth);

  final AppDatabase _db;
  final AuthService _auth;

  /// Writes a JSON export of all the user's data to a temporary file and
  /// returns its path (for sharing). Raw coordinates are excluded — only the
  /// derived H3 cells in profile are included (see [AppDatabase.exportUserData]).
  Future<String> writeExportFile() async {
    final data = await _db.exportUserData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'tendask-export.json'));
    await file.writeAsString(json);
    return file.path;
  }

  /// Permanently deletes the account: removes the cloud account (cascades to all
  /// cloud rows) when signed in, then wipes the local database. A guest has no
  /// cloud account — just the local wipe. Returns to a clean onboarding state.
  Future<void> deleteAccount() async {
    await _auth.deleteAccount();
    await _db.clearUserData();
  }
}
