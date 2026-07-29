import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/core/location/h3_cells.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/task_specs.dart';
import 'package:tendask/features/weather/application/weather_service.dart';
import 'package:tendask/features/weather/data/open_meteo_client.dart';
import 'package:tendask/features/weather/data/open_meteo_response.dart';

/// Counts every transport call, so "we never asked Open-Meteo" is asserted, not
/// assumed — the whole point of FR-22 is that no location means no request.
class _CountingClient implements OpenMeteoClient {
  int calls = 0;

  @override
  Future<OpenMeteoResponse> fetch({
    required double latitude,
    required double longitude,
  }) async {
    calls++;
    return const OpenMeteoResponse(
      current: OpenMeteoCurrent(temperature2m: 20),
    );
  }

  @override
  Future<OpenMeteoResponse> fetchCurrent({
    required double latitude,
    required double longitude,
  }) => fetch(latitude: latitude, longitude: longitude);
}

void main() {
  late AppDatabase db;
  late _CountingClient client;

  const userId = 'user-1';
  const areaId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  final t0 = DateTime.utc(2026, 7, 29, 8);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = _CountingClient();
    await SeedService(db).runIfNeeded();
  });

  tearDown(() async => db.close());

  ProviderContainer containerWith(GardenCoords? location) {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        openMeteoClientProvider.overrideWithValue(client),
        gardenLocationProvider.overrideWith((ref) => Stream.value(location)),
      ],
    );
    addTearDown(container.dispose);
    // A stream provider nobody listens to never starts its subscription, so
    // `read(.future)` would hang. Home watches the location for real; stand in
    // for it here.
    addTearDown(container.listen(gardenLocationProvider, (_, _) {}).close);
    return container;
  }

  group('without a garden location', () {
    test('currentWeather is null and never calls Open-Meteo', () async {
      final container = containerWith(null);
      // Both weather providers are autoDispose: read without a listener they
      // are torn down before their future settles, so subscribe first.
      addTearDown(container.listen(currentWeatherProvider, (_, _) {}).close);

      expect(await container.read(currentWeatherProvider.future), isNull);
      expect(client.calls, 0);
    });

    test('weatherDetail is null and never calls Open-Meteo', () async {
      final container = containerWith(null);
      addTearDown(container.listen(weatherDetailProvider, (_, _) {}).close);

      expect(await container.read(weatherDetailProvider.future), isNull);
      expect(client.calls, 0);
    });

    test('completing a task freezes no snapshot', () async {
      final container = containerWith(null);
      final repo = container.read(tasksRepositoryProvider);
      final id = await repo.create(
        userId: userId,
        taskTypeId: 'water',
        date: t0,
        subjects: const [TaskSubjectSpec.area(areaId)],
        status: TaskStatus.done,
      );
      // The capture is fire-and-forget; let it run before reading the row back.
      await pumpEventQueue();

      expect((await repo.byId(id))?.weather, isNull);
      expect(client.calls, 0);
    });
  });

  group('with a garden location', () {
    test('currentWeather fetches for the given coordinates', () async {
      final container = containerWith((latitude: 46.5, longitude: 15.6));
      addTearDown(container.listen(currentWeatherProvider, (_, _) {}).close);

      expect(await container.read(currentWeatherProvider.future), isNotNull);
      expect(client.calls, 1);
    });

    test('completing a task freezes a snapshot', () async {
      final container = containerWith((latitude: 46.5, longitude: 15.6));
      final repo = container.read(tasksRepositoryProvider);
      final id = await repo.create(
        userId: userId,
        taskTypeId: 'water',
        date: t0,
        subjects: const [TaskSubjectSpec.area(areaId)],
        status: TaskStatus.done,
      );
      await pumpEventQueue();

      expect((await repo.byId(id))?.weather, isNotNull);
      expect(client.calls, 1);
    });
  });
}
