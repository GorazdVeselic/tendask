import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';

void main() {
  late AppDatabase db;
  late LocalPrefsRepository prefs;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = LocalPrefsRepository(db);
  });
  tearDown(() => db.close());

  test('pending sign-in email round-trips and clears', () async {
    expect(await prefs.pendingSignInEmail(), isNull);

    await prefs.setPendingSignInEmail('jan@firma.si');
    expect(await prefs.pendingSignInEmail(), 'jan@firma.si');

    await prefs.clearPendingSignInEmail();
    expect(await prefs.pendingSignInEmail(), isNull);
  });

  test('setPendingSignInEmail overwrites a previous value', () async {
    await prefs.setPendingSignInEmail('a@x.si');
    await prefs.setPendingSignInEmail('b@y.si');
    expect(await prefs.pendingSignInEmail(), 'b@y.si');
  });
}
