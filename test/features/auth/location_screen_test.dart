import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/location/geocoding_client.dart';
import 'package:tendask/core/location/location_service.dart';
import 'package:tendask/features/auth/presentation/location_screen.dart';
import 'package:tendask/features/auth/presentation/widgets/gps_card.dart';
import 'package:tendask/features/auth/presentation/widgets/location_status_banner.dart';
import 'package:tendask/i18n/translations.g.dart';

import '../../core/location/fake_location_repository.dart';

const _place = GeoPlace(
  name: 'Šentjur',
  latitude: 46.2,
  longitude: 15.4,
  admin1: 'Savinjska',
  country: 'Slovenija',
);

/// A GPS attempt whose outcome the test controls, including its timing — an
/// unfinished future is how the loading state is held open.
class _FakeLocationService implements LocationService {
  const _FakeLocationService(this.result);

  final Future<LocationResult> result;

  @override
  Future<LocationResult> currentCoordinates() => result;
}

class _FakeGeocodingClient implements GeocodingClient {
  const _FakeGeocodingClient(this.matches);

  final List<GeoPlace> matches;

  @override
  Future<List<GeoPlace>> search(String query, {String language = 'en'}) async =>
      matches;
}

/// Pumps the screen inside a router: entering at `/location` is the onboarding
/// step (nothing to pop back to), pushing it from `/settings` is the settings
/// mode the screen tells apart with `canPop()`.
Future<GoRouter> pumpLocationScreen(
  WidgetTester tester, {
  required FakeLocationRepository repository,
  Future<LocationResult>? gps,
  List<GeoPlace> matches = const [],
  String? placeLabel,
  bool fromSettings = false,
}) async {
  final router = GoRouter(
    initialLocation: fromSettings ? '/settings' : '/location',
    routes: [
      GoRoute(path: '/location', builder: (_, _) => const LocationScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const Scaffold(body: Text('SETTINGS')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          ...locationOverrides(repository, placeLabel: placeLabel),
          // A guest: no Supabase client, so rows are owned by kLocalUserId.
          authServiceProvider.overrideWithValue(AuthService(null)),
          locationServiceProvider.overrideWithValue(
            _FakeLocationService(
              gps ?? Future.value(const LocationUnavailable()),
            ),
          ),
          geocodingClientProvider.overrideWithValue(
            _FakeGeocodingClient(matches),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  // The push future completes only when the screen pops, which is never here.
  if (fromSettings) unawaited(router.push('/location'));
  await tester.pumpAndSettle();
  return router;
}

String currentPath(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

final skipButton = find.widgetWithText(OutlinedButton, t.location.skip);
final continueButton = find.widgetWithText(FilledButton, t.location.kContinue);

GpsCard gpsCard(WidgetTester tester) => tester.widget(find.byType(GpsCard));

/// Scopes a finder to the status banner — the place name also sits in the
/// search field, which `find.text` would match just as happily.
Finder inBanner(Finder matching) =>
    find.descendant(of: find.byType(LocationStatusBanner), matching: matching);

void main() {
  group('onboarding', () {
    testWidgets('unset: the GPS card is the only emphasised surface', (
      tester,
    ) async {
      await pumpLocationScreen(tester, repository: FakeLocationRepository());

      expect(gpsCard(tester).emphasised, isTrue);
      expect(skipButton, findsOneWidget);
      // The whole point of FR-24: nothing filled leads past the step.
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('unset: skip reaches home in one tap and stores nothing', (
      tester,
    ) async {
      final repository = FakeLocationRepository();
      final router = await pumpLocationScreen(tester, repository: repository);

      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(currentPath(router), '/home');
      expect(repository.cell, isNull);
      expect(repository.saved, isEmpty);
    });

    testWidgets('picking a place flips the emphasis and names the banner', (
      tester,
    ) async {
      final repository = FakeLocationRepository();
      await pumpLocationScreen(
        tester,
        repository: repository,
        matches: const [_place],
      );

      await tester.enterText(find.byType(TextField), _place.name);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, _place.name));
      await tester.pumpAndSettle();

      expect(repository.saved, [
        (latitude: _place.latitude, longitude: _place.longitude),
      ]);
      // No label was resolved (as when offline), yet the banner still confirms
      // by name — the screen keeps the place the user just picked.
      expect(inBanner(find.text(t.location.status_set)), findsOneWidget);
      expect(inBanner(find.text(_place.name)), findsOneWidget);
      expect(gpsCard(tester).emphasised, isFalse);
      expect(continueButton, findsOneWidget);
      expect(skipButton, findsNothing);
    });

    testWidgets('set: the resolved place name reaches the banner', (
      tester,
    ) async {
      await pumpLocationScreen(
        tester,
        repository: FakeLocationRepository(
          cell: FakeLocationRepository.savedCell,
        ),
        placeLabel: _place.name,
      );

      // Two lines: the status above, the place and its remove action below.
      expect(inBanner(find.text(t.location.status_set)), findsOneWidget);
      expect(inBanner(find.text(_place.name)), findsOneWidget);
      expect(find.widgetWithText(TextButton, t.location.clear), findsOneWidget);
    });

    testWidgets('set: continue is the emphasised way out', (tester) async {
      final router = await pumpLocationScreen(
        tester,
        repository: FakeLocationRepository(
          cell: FakeLocationRepository.savedCell,
        ),
        placeLabel: _place.name,
      );

      expect(gpsCard(tester).emphasised, isFalse);
      expect(skipButton, findsNothing);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(currentPath(router), '/home');
    });

    testWidgets('removing the location brings the emphasis back', (
      tester,
    ) async {
      final repository = FakeLocationRepository(
        cell: FakeLocationRepository.savedCell,
      );
      await pumpLocationScreen(
        tester,
        repository: repository,
        placeLabel: _place.name,
      );

      // Both buttons read "Remove" in some locales, so match on the type too.
      await tester.tap(find.widgetWithText(TextButton, t.location.clear));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, t.location.clear_confirm_yes),
      );
      await tester.pumpAndSettle();

      expect(repository.cell, isNull);
      expect(find.text(t.location.status_unset), findsOneWidget);
      expect(gpsCard(tester).emphasised, isTrue);
      expect(skipButton, findsOneWidget);
    });

    testWidgets('a refused GPS attempt explains itself and blocks nothing', (
      tester,
    ) async {
      final repository = FakeLocationRepository();
      final router = await pumpLocationScreen(
        tester,
        repository: repository,
        gps: Future.value(const LocationDenied(permanent: false)),
      );

      await tester.tap(find.byType(GpsCard));
      await tester.pumpAndSettle();

      expect(find.text(t.location.err_denied), findsOneWidget);
      expect(repository.cell, isNull);
      // A refusal is a legitimate attempt, not a wrong turn: the card keeps its
      // emphasis and the user can still type a place or skip.
      expect(gpsCard(tester).emphasised, isTrue);

      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(currentPath(router), '/home');
    });

    testWidgets('a slow GPS fix disables the card but never the way out', (
      tester,
    ) async {
      final repository = FakeLocationRepository();
      final fix = Completer<LocationResult>();
      await pumpLocationScreen(tester, repository: repository, gps: fix.future);

      await tester.tap(find.byType(GpsCard));
      await tester.pump();

      expect(gpsCard(tester).loading, isTrue);
      expect(tester.widget<OutlinedButton>(skipButton).onPressed, isNotNull);

      fix.complete(const LocationCoords(46.2, 15.4));
      await tester.pumpAndSettle();

      expect(repository.cell, FakeLocationRepository.savedCell);
      // A fix carries no place name, so the banner confirms without one.
      expect(find.text(t.location.status_set), findsOneWidget);
      expect(continueButton, findsOneWidget);
    });

    testWidgets('the keyboard pushes the bottom block back into the list', (
      tester,
    ) async {
      await pumpLocationScreen(tester, repository: FakeLocationRepository());

      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.reset);
      await tester.pump();

      // The pinned pair would eat the list that holds the search matches; the
      // GPS option steps back into the list rather than disappearing (it sits
      // below the fold there, hence the scroll).
      expect(skipButton, findsNothing);
      await tester.dragUntilVisible(
        find.byType(GpsCard),
        find.byType(ListView),
        const Offset(0, -120),
      );
      expect(gpsCard(tester).emphasised, isFalse);
    });
  });

  group('from settings', () {
    testWidgets('no call to action and no way out — a pick saves on the spot', (
      tester,
    ) async {
      await pumpLocationScreen(
        tester,
        repository: FakeLocationRepository(),
        fromSettings: true,
      );

      expect(find.text(t.location.screen_title), findsOneWidget);
      expect(skipButton, findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(gpsCard(tester).emphasised, isFalse);
    });
  });
}
