import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime.utc(2026, 6, 5, 10);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed() async {
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u1',
            h3R7: const Value('871f1d4ffffffff'),
            updatedAt: t0,
          ),
        );
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
  }

  group('exportUserData', () {
    test('includes user rows, omits internal sync_status', () async {
      await seed();
      final export = await db.exportUserData();

      final areas = export['area'] as List;
      expect(areas, hasLength(1));
      final area = areas.single as Map<String, dynamic>;
      expect(area['name'], 'Greda');
      expect(area.containsKey('syncStatus'), isFalse);

      expect(export['task'], hasLength(1));
      expect((export['profile'] as List).single['h3R7'], '871f1d4ffffffff');
    });

    test('never exposes raw coordinates (privacy by design)', () async {
      await seed();
      final export = await db.exportUserData();

      // Raw coordinates are never stored (FR-8): no device_location section and
      // no latitude/longitude anywhere — only the derived H3 cells in profile.
      expect(export.containsKey('device_location'), isFalse);
      final dump = export.toString();
      expect(dump.contains('latitude'), isFalse);
      expect(dump.contains('longitude'), isFalse);
    });
  });
}
