import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime.utc(2026, 6, 5, 10);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  // Seeds one row in each relevant table: user data, device-local data, the
  // pull cursor, the catalog (public), and a local flag (onboarding).
  Future<void> seed() async {
    await db
        .into(db.areas)
        .insert(
          AreasCompanion.insert(
            id: 'a1',
            userId: 'u1',
            name: 'Greda',
            updatedAt: t0,
          ),
        );
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: 't1',
            userId: 'u1',
            taskTypeId: 'water',
            date: t0,
            updatedAt: t0,
          ),
        );
    await db
        .into(db.deviceLocations)
        .insert(
          DeviceLocationsCompanion.insert(
            latitude: 46.0,
            longitude: 14.5,
            updatedAt: t0,
          ),
        );
    await db
        .into(db.syncCursors)
        .insert(SyncCursorsCompanion.insert(name: 'pull', lastPulledAt: t0));
    await db
        .into(db.taskTypes)
        .insert(
          TaskTypesCompanion.insert(
            id: 'water',
            labels: '{}',
            icon: '💧',
            category: 'care',
          ),
        );
    await db
        .into(db.localFlags)
        .insert(LocalFlagsCompanion.insert(key: 'onboardingSeen', value: '1'));
  }

  Future<int> count(TableInfo<Table, dynamic> t) async =>
      (await db.select(t).get()).length;

  group('clearUserData', () {
    test('wipes user + device-local data but keeps the catalog', () async {
      await seed();
      await db.clearUserData(keepFlags: true);

      expect(await count(db.areas), 0);
      expect(await count(db.tasks), 0);
      expect(await count(db.deviceLocations), 0); // coordinates gone on reset
      expect(await count(db.syncCursors), 0); // forces a full pull next sign-in
      expect(await count(db.taskTypes), 1); // catalog is public, kept
    });

    test('keepFlags: true preserves the onboarding flag', () async {
      await seed();
      await db.clearUserData(keepFlags: true);
      expect(await count(db.localFlags), 1);
    });

    test(
      'keepFlags: false also clears local flags (full sign-out reset)',
      () async {
        await seed();
        await db.clearUserData(keepFlags: false);
        expect(await count(db.localFlags), 0);
        expect(await count(db.taskTypes), 1); // catalog still kept
      },
    );
  });
}
