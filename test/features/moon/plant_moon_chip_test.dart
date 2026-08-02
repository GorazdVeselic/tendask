import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/moon/presentation/widgets/plant_moon_chip.dart';
import 'package:tendask/i18n/translations.g.dart';

final _tomato = Plant(
  id: 'tomato',
  labels: jsonEncode({'sl': 'paradižnik', 'en': 'tomato', 'de': 'Tomate'}),
  scientificName: null,
  category: 'vegetable',
  icon: '🍅',
);

void main() {
  testWidgets('the dark gate renders nothing, even without a ProviderScope', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: PlantMoonChip(plant: _tomato)),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('the chip opens the finder prefilled with the plant', (
    tester,
  ) async {
    String? receivedPlant;
    final router = GoRouter(
      initialLocation: '/plant',
      routes: [
        GoRoute(
          path: '/plant',
          builder: (_, _) => const Scaffold(
            body: PlantMoonChipButton(plantId: 'tomato'),
          ),
        ),
        GoRoute(
          path: '/moon-finder',
          name: 'moon-finder',
          builder: (_, state) {
            receivedPlant = state.uri.queryParameters['plant'];
            return const Scaffold(body: Text('MOON-FINDER'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.moon.finder.title), findsOneWidget);
    await tester.tap(find.byType(ActionChip));
    await tester.pumpAndSettle();

    expect(find.text('MOON-FINDER'), findsOneWidget);
    expect(receivedPlant, 'tomato');
  });
}
