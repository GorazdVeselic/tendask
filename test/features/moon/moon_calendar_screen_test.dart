import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/core/widgets/sheet_handle.dart';
import 'package:tendask/features/moon/application/garden_elements_provider.dart';
import 'package:tendask/features/moon/presentation/moon_calendar_screen.dart';
import 'package:tendask/features/moon/presentation/moon_day_sheet.dart';
import 'package:tendask/features/moon/presentation/moon_settings_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        gardenElementsProvider.overrideWithValue(const <BiodynamicElement>{}),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpCalendar(WidgetTester tester, {GoRouter? router}) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final app = router != null
        ? MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          )
        : const MaterialApp(
            home: MoonCalendarScreen(),
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

  testWidgets('tapping a month cell opens the day sheet', (tester) async {
    await pumpCalendar(tester);
    expect(find.byType(SheetHandle), findsNothing);

    // Mid-month day: always in the current month and unique in the grid.
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.byType(SheetHandle), findsOneWidget);
    // The astro details block is on by default.
    expect(find.byKey(kMoonWhatsHappeningKey), findsOneWidget);
  });

  testWidgets('tapping a week agenda row opens the day sheet', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(find.text(t.moon.calendar.week_view));
    await tester.pumpAndSettle();

    await tester.tap(find.text('${DateTime.now().day}'));
    await tester.pumpAndSettle();

    expect(find.byType(SheetHandle), findsOneWidget);
  });

  testWidgets('the astro sub-toggle hides the whats-happening block', (
    tester,
  ) async {
    await LocalPrefsRepository(db).setMoonShowAstroDetails(false);

    await pumpCalendar(tester);
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.byType(SheetHandle), findsOneWidget);
    expect(find.byKey(kMoonWhatsHappeningKey), findsNothing);
  });

  testWidgets('the month arrows navigate to the adjacent month', (
    tester,
  ) async {
    await pumpCalendar(tester);
    final ml = MaterialLocalizations.of(
      tester.element(find.byType(MoonCalendarScreen)),
    );
    final now = DateTime.now();
    final thisMonth = ml.formatMonthYear(DateTime(now.year, now.month));
    final nextMonth = ml.formatMonthYear(DateTime(now.year, now.month + 1));
    expect(find.text(thisMonth), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.text(nextMonth), findsOneWidget);
    expect(find.text(thisMonth), findsNothing);
  });

  testWidgets('the sheet "+ task" CTA opens the prefilled task form', (
    tester,
  ) async {
    String? receivedDate;
    final router = GoRouter(
      initialLocation: '/moon-calendar',
      routes: [
        GoRoute(
          path: '/moon-calendar',
          builder: (_, _) => const MoonCalendarScreen(),
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
    await pumpCalendar(tester, router: router);
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.moon.sheet.add_task).first);
    await tester.pumpAndSettle();

    expect(find.text('TASK-NEW'), findsOneWidget);
    final now = DateTime.now();
    expect(
      DateTime.tryParse(receivedDate ?? ''),
      DateTime(now.year, now.month, 15),
    );
  });

  testWidgets('the AppBar gear opens /moon-settings', (tester) async {
    final router = GoRouter(
      initialLocation: '/moon-calendar',
      routes: [
        GoRoute(
          path: '/moon-calendar',
          builder: (_, _) => const MoonCalendarScreen(),
        ),
        GoRoute(
          path: '/moon-settings',
          name: 'moon-settings',
          builder: (_, _) => const MoonSettingsScreen(),
        ),
      ],
    );
    await pumpCalendar(tester, router: router);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(MoonSettingsScreen), findsOneWidget);
  });
}
