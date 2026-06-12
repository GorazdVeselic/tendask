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
            timezone: const Value('Europe/Ljubljana'),
            climateBucket: const Value('e1_t5'),
            climateProfile: const Value('{"frost_free":false}'),
            fcmToken: const Value('secret-device-token'),
            fcmTokenUpdatedAt: Value(t0),
            updatedAt: t0,
          ),
        );
    await db
        .into(db.suggestions)
        .insert(
          SuggestionsCompanion.insert(
            id: 's1',
            userId: 'u1',
            ruleId: 'R5',
            taskTypeId: 'water',
            subjectKey: 'cat:vegetable',
            messageKey: 'suggestions.water',
            score: 2.0,
            validUntil: t0,
            createdAt: t0,
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
    // Device-local raw coordinates — must NOT appear in the export.
    await db
        .into(db.deviceLocations)
        .insert(
          DeviceLocationsCompanion.insert(
            latitude: 46.0512,
            longitude: 14.5051,
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

    test('includes suggestions and climate fields, strips the FCM token', () async {
      await seed();
      final export = await db.exportUserData();

      final suggestions = export['suggestion'] as List;
      expect(suggestions, hasLength(1));
      expect((suggestions.single as Map)['messageKey'], 'suggestions.water');

      final profile = (export['profile'] as List).single as Map;
      expect(profile['timezone'], 'Europe/Ljubljana');
      expect(profile['climateBucket'], 'e1_t5');
      expect(profile['climateProfile'], '{"frost_free":false}');
      // Technical device identifier — never part of the GDPR export.
      expect(profile.containsKey('fcmToken'), isFalse);
      expect(profile.containsKey('fcmTokenUpdatedAt'), isFalse);
      expect(export.toString().contains('secret-device-token'), isFalse);
    });

    test('never exposes raw coordinates (privacy by design)', () async {
      await seed();
      final export = await db.exportUserData();

      // No device_location section, and the coordinate values appear nowhere.
      expect(export.containsKey('device_location'), isFalse);
      final dump = export.toString();
      expect(dump.contains('46.0512'), isFalse);
      expect(dump.contains('14.5051'), isFalse);
    });
  });
}
