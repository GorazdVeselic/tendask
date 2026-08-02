import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/date_format.dart';
import 'package:tendask/core/widgets/sheet_handle.dart';
import 'package:tendask/features/moon/application/moon_finder.dart';
import 'package:tendask/features/moon/presentation/moon_finder_screen.dart';
import 'package:tendask/features/moon/presentation/moon_text.dart';
import 'package:tendask/features/plants/presentation/plant_picker_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

/// A fruit plant (override), and one the sowing calendar says nothing about.
Plant _plant(String id, String label, String category) => Plant(
  id: id,
  labels: jsonEncode({'sl': label, 'en': label, 'de': label}),
  scientificName: null,
  category: category,
  icon: '🌿',
);

final _tomato = _plant('tomato', 'tomato', 'vegetable');
final _monstera = _plant('monstera', 'monstera', 'houseplant');

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        plantsMapProvider.overrideWith(
          (ref) => Stream.value({'tomato': _tomato, 'monstera': _monstera}),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpFinder(
    WidgetTester tester, {
    String? plantId,
    GoRouter? router,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final app = router != null
        ? MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          )
        : MaterialApp(
            home: MoonFinderScreen(initialPlantId: plantId),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(child: app),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The runs the screen must be showing, computed the way it computes them.
  List<MoonDayRun> expectedRuns() => moonDayRuns(
    from: startOfDay(DateTime.now()),
    element: BiodynamicElement.fruit,
    system: CalendarSystem.sidereal,
  );

  String rangeLabel(MoonDayRun run) {
    final start = '${weekdayShort(t, run.start)} ${formatDm(run.start)}';
    if (run.start == run.end) return start;
    return '$start – ${weekdayShort(t, run.end)} ${formatDm(run.end)}';
  }

  testWidgets('a prefilled plant answers with its element and its days', (
    tester,
  ) async {
    await pumpFinder(tester, plantId: 'tomato');

    expect(
      find.text(
        t.moon.finder.callout(
          plant: sentenceCase('tomato'),
          day: t.moon.day_for[BiodynamicElement.fruit.name]!,
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(t.moon.finder.next_days.toUpperCase()), findsOneWidget);
    expect(find.text(rangeLabel(expectedRuns().first)), findsOneWidget);
  });

  testWidgets('a plant outside the calendar gets a calm note, not days', (
    tester,
  ) async {
    await pumpFinder(tester, plantId: 'monstera');

    expect(find.text(t.moon.finder.no_recommendation), findsOneWidget);
    expect(find.text(t.moon.finder.next_days.toUpperCase()), findsNothing);
  });

  testWidgets('with nothing picked the screen hints instead of listing', (
    tester,
  ) async {
    await pumpFinder(tester);

    expect(find.text(t.moon.finder.empty_hint), findsOneWidget);
    expect(find.text(t.moon.finder.next_days.toUpperCase()), findsNothing);
  });

  testWidgets('tapping a stretch opens the day sheet of its first day', (
    tester,
  ) async {
    await pumpFinder(tester, plantId: 'tomato');
    expect(find.byType(SheetHandle), findsNothing);

    final run = expectedRuns().first;
    await tester.tap(find.text(rangeLabel(run)));
    await tester.pumpAndSettle();

    expect(find.byType(SheetHandle), findsOneWidget);
    final ml = MaterialLocalizations.of(
      tester.element(find.byType(MoonFinderScreen)),
    );
    expect(
      find.text(sentenceCase(ml.formatFullDate(run.start))),
      findsOneWidget,
    );
  });

  testWidgets('the "+" opens the task form prefilled with the first day', (
    tester,
  ) async {
    String? receivedDate;
    final router = GoRouter(
      initialLocation: '/moon-finder',
      routes: [
        GoRoute(
          path: '/moon-finder',
          builder: (_, _) => const MoonFinderScreen(initialPlantId: 'tomato'),
        ),
        GoRoute(
          path: '/task-new',
          name: 'task-new',
          builder: (_, state) {
            receivedDate = state.uri.queryParameters['date'];
            return const Scaffold(body: Text('TASK-NEW'));
          },
        ),
      ],
    );
    await pumpFinder(tester, router: router);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('TASK-NEW'), findsOneWidget);
    expect(DateTime.tryParse(receivedDate ?? ''), expectedRuns().first.start);
  });

  testWidgets('picking a plant in the picker moves the answer with it', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/moon-finder',
      routes: [
        GoRoute(
          path: '/moon-finder',
          builder: (_, _) => const MoonFinderScreen(),
        ),
        GoRoute(
          path: '/plant-picker',
          name: 'plant-picker',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop<PlantPick>((
                plantId: 'tomato',
                customName: null,
              )),
              child: const Text('PICK'),
            ),
          ),
        ),
      ],
    );
    await pumpFinder(tester, router: router);
    expect(find.text(t.moon.finder.empty_hint), findsOneWidget);

    await tester.tap(find.text(t.moon.finder.plant_hint));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PICK'));
    await tester.pumpAndSettle();

    expect(find.text(t.moon.finder.next_days.toUpperCase()), findsOneWidget);
    expect(find.text(rangeLabel(expectedRuns().first)), findsOneWidget);
  });
}
