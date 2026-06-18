import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/location/h3_cells.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/sync/sync_status.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;
  @override
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

// Canned H3: the real native library can't load under `flutter test` (FFI), so
// we return fixed cells/centroid. This exercises the repository wiring, not the
// H3 math (which on-device verification covers).
const _r7 = '871f8d4ffffffff';
const _r6 = '861f8d4f7ffffff';
const _r5 = '851f8d4ffffffff';

class _FakeH3 implements H3 {
  @override
  BigInt geoToCell(GeoCoord geoCoord, int resolution) =>
      BigInt.parse(_r7, radix: 16);

  @override
  BigInt cellToParent(BigInt h3Index, int resolution) =>
      BigInt.parse(resolution == 6 ? _r6 : _r5, radix: 16);

  @override
  GeoCoord cellToGeo(BigInt h3Index) => const GeoCoord(lat: 46.05, lon: 14.51);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late LocationRepository repo;

  final t0 = DateTime.utc(2026, 6, 18, 8);
  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = _FakeClock(t0);
    repo = LocationRepository(db, _FakeH3(), clock: clock);
  });

  tearDown(() async => db.close());

  Future<Profile?> profileRow() =>
      (db.select(db.profiles)..where((p) => p.userId.equals(userId)))
          .getSingleOrNull();

  group('saveGardenLocation', () {
    test('writes the derived profile cells and marks them pending', () async {
      await repo.saveGardenLocation(
        userId: userId,
        latitude: 46.05,
        longitude: 14.51,
      );
      final row = await profileRow();
      expect(row, isNotNull);
      expect(row!.h3R7, _r7);
      expect(row.h3R6, _r6);
      expect(row.h3R5, _r5);
      expect(row.syncStatus, kSyncPending);
      // drift reads DateTime back as local; compare the instant, not the flag.
      expect(row.updatedAt.isAtSameMomentAs(t0), isTrue);
    });

    test('updates an existing profile without clobbering lang', () async {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              userId: userId,
              lang: const Value('sl'),
              updatedAt: t0,
            ),
          );
      clock.advance(const Duration(hours: 1));
      await repo.saveGardenLocation(
        userId: userId,
        latitude: 46.05,
        longitude: 14.51,
      );
      final row = await profileRow();
      expect(row!.lang, 'sl');
      expect(row.h3R7, _r7);
      expect(row.syncStatus, kSyncPending);
    });
  });

  test('clearGardenLocation nulls the cells and marks pending', () async {
    await repo.saveGardenLocation(
      userId: userId,
      latitude: 46.05,
      longitude: 14.51,
    );
    clock.advance(const Duration(hours: 2));
    await repo.clearGardenLocation(userId);
    final row = await profileRow();
    expect(row!.h3R7, isNull);
    expect(row.h3R6, isNull);
    expect(row.h3R5, isNull);
    expect(row.syncStatus, kSyncPending);
  });

  group('gardenCell', () {
    test('returns null when unset, the r7 cell once saved', () async {
      expect(await repo.gardenCell(), isNull);
      await repo.saveGardenLocation(
        userId: userId,
        latitude: 46.05,
        longitude: 14.51,
      );
      expect(await repo.gardenCell(), _r7);
    });
  });

  test('watchGardenCell emits null then the saved cell', () async {
    final emissions = <String?>[];
    final sub = repo.watchGardenCell().listen(emissions.add);
    await pumpEventQueue();
    await repo.saveGardenLocation(
      userId: userId,
      latitude: 46.05,
      longitude: 14.51,
    );
    await pumpEventQueue();
    expect(emissions, [null, _r7]);
    await sub.cancel();
  });

  group('gardenLocation provider', () {
    Future<GardenCoords> firstLocation() async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
          h3Provider.overrideWith((ref) => _FakeH3()),
        ],
      );
      addTearDown(container.dispose);
      final completer = Completer<GardenCoords>();
      final sub = container.listen<AsyncValue<GardenCoords>>(
        gardenLocationProvider,
        (_, next) {
          if (next.hasValue && !completer.isCompleted) {
            completer.complete(next.value);
          }
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);
      return completer.future.timeout(const Duration(seconds: 5));
    }

    test('emits the cell centroid once a location is set', () async {
      await repo.saveGardenLocation(
        userId: userId,
        latitude: 46.05,
        longitude: 14.51,
      );
      final coords = await firstLocation();
      expect(coords.latitude, closeTo(46.05, 1e-9));
      expect(coords.longitude, closeTo(14.51, 1e-9));
    });

    test('emits the default region when no location is set', () async {
      final coords = await firstLocation();
      expect(coords.latitude, kDefaultLatitude);
      expect(coords.longitude, kDefaultLongitude);
    });
  });
}
