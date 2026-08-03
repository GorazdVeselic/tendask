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

  test('moonShowElementLabels distinguishes never-set from switched off',
      () async {
    expect(await prefs.moonShowElementLabels(), isNull);

    await prefs.setMoonShowElementLabels(false);
    expect(await prefs.moonShowElementLabels(), isFalse);

    await prefs.setMoonShowElementLabels(true);
    expect(await prefs.moonShowElementLabels(), isTrue);
  });

  test('a corrupted moon flag reads as switched off, never as default-on',
      () async {
    // Only the app writes this key ('true'/'false'); anything else must not
    // read as null (null means never-set and defaults to ON).
    await db
        .into(db.localFlags)
        .insertOnConflictUpdate(
          LocalFlagsCompanion.insert(
            key: 'moon_show_element_labels',
            value: 'yes',
          ),
        );
    expect(await prefs.moonShowElementLabels(), isFalse);
  });

  test('moonSystem round-trips and overwrites', () async {
    expect(await prefs.moonSystem(), isNull);

    await prefs.setMoonSystem('tropical');
    expect(await prefs.moonSystem(), 'tropical');

    await prefs.setMoonSystem('sidereal');
    expect(await prefs.moonSystem(), 'sidereal');
  });
}
