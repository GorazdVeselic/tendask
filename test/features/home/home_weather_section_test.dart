import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/location/h3_cells.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/location/place_label_repository.dart';
import 'package:tendask/features/home/presentation/widgets/home_weather_section.dart';
import 'package:tendask/features/weather/application/weather_service.dart';
import 'package:tendask/features/weather/data/weather_snapshot.dart';
import 'package:tendask/features/weather/presentation/weather_card.dart';
import 'package:tendask/features/weather/presentation/weather_no_location_card.dart';
import 'package:tendask/i18n/translations.g.dart';

const _gardenPoint = (latitude: 46.22, longitude: 15.39);

WeatherSnapshot _snapshot() => WeatherSnapshot(
  capturedAt: DateTime.utc(2026, 7, 29, 9),
  temperature: 24,
  weatherCode: 3,
);

List<Override> _overrides({
  required GardenCoords? location,
  required WeatherSnapshot? weather,
}) => [
  gardenLocationProvider.overrideWith((ref) => Stream.value(location)),
  currentWeatherProvider.overrideWith((ref) async => weather),
  for (final locale in AppLocale.values)
    placeLabelProvider(locale.languageCode).overrideWith((ref) async => null),
];

/// The section inside a router, so its CTA has somewhere to push to.
Future<GoRouter> _pump(
  WidgetTester tester, {
  required GardenCoords? location,
  WeatherSnapshot? weather,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: HomeWeatherSection()),
      ),
      GoRoute(
        path: '/location',
        builder: (_, _) => const Scaffold(body: Text('location screen')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: _overrides(location: location, weather: weather),
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  // Explicit pumps: the location stream and the weather future both resolve a
  // microtask after the first frame.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return router;
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('without a location it invites, and shows no weather', (
    tester,
  ) async {
    await _pump(tester, location: null, weather: _snapshot());

    expect(find.byType(WeatherNoLocationCard), findsOne);
    expect(find.byType(CurrentWeatherCard), findsNothing);
    expect(find.text(t.weather.no_location_title), findsOne);
  });

  testWidgets('with a location and a snapshot it shows the weather', (
    tester,
  ) async {
    await _pump(tester, location: _gardenPoint, weather: _snapshot());

    expect(find.byType(CurrentWeatherCard), findsOne);
    expect(find.byType(WeatherNoLocationCard), findsNothing);
    expect(find.text('24°C'), findsOne);
  });

  testWidgets('with a location but no snapshot it stays a quiet card', (
    tester,
  ) async {
    await _pump(tester, location: _gardenPoint, weather: null);

    // Offline is not an invite: the location is known, the data is not.
    expect(find.byType(WeatherNoLocationCard), findsNothing);
    expect(find.text(t.weather.home_unavailable), findsOne);
    expect(find.text(t.weather.home_retry), findsOne);
  });

  testWidgets('tapping the card pushes the location screen', (tester) async {
    // The whole card is the target — the underlined word in the sentence is a
    // cue, not the only 60 px worth of tappable surface.
    await _pump(tester, location: null);

    await tester.tap(find.text(t.weather.no_location_title));
    await tester.pumpAndSettle();

    expect(find.text('location screen'), findsOne);
  });

  testWidgets('setting a location swaps the invite for weather, unprompted', (
    tester,
  ) async {
    // The promise the section makes: the cell is a stream and the card watches
    // it, so returning from the location screen needs no manual refresh.
    final location = StreamController<GardenCoords?>();
    addTearDown(location.close);

    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            gardenLocationProvider.overrideWith((ref) => location.stream),
            currentWeatherProvider.overrideWith((ref) async => _snapshot()),
            for (final locale in AppLocale.values)
              placeLabelProvider(
                locale.languageCode,
              ).overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeWeatherSection())),
        ),
      ),
    );

    location.add(null);
    await tester.pump();
    expect(find.byType(WeatherNoLocationCard), findsOne);

    location.add(_gardenPoint);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CurrentWeatherCard), findsOne);
    expect(find.byType(WeatherNoLocationCard), findsNothing);
  });
}
