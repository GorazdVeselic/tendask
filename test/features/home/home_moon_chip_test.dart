import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/features/home/presentation/widgets/home_moon_chip.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pump(WidgetTester tester, Widget child, {GoRouter? router}) {
    final app = router != null
        ? MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          )
        : MaterialApp(
            home: Scaffold(body: child),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(child: app),
      ),
    );
  }

  testWidgets('the gate renders nothing while the feature flag is dark', (
    tester,
  ) async {
    // Guards main-safety today (kMoonCalendarEnabled is false until T7): the
    // dashboard must stay pixel-identical with the chip mounted.
    await pump(tester, const HomeMoonChip());
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
    expect(find.text(t.moon.calendar.title), findsNothing);
  });

  testWidgets('the card shows the phase and opens /moon-calendar on tap', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: HomeMoonChipCard()),
        ),
        GoRoute(
          path: '/moon-calendar',
          builder: (_, _) => const Scaffold(body: Text('MOON-CALENDAR')),
        ),
      ],
    );
    await pump(tester, const SizedBox.shrink(), router: router);
    await tester.pumpAndSettle();

    expect(find.text(t.moon.calendar.title), findsOneWidget);

    await tester.tap(find.byType(HomeMoonChipCard));
    await tester.pumpAndSettle();

    expect(find.text('MOON-CALENDAR'), findsOneWidget);
  });
}
