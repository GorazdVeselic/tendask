import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/features/home/presentation/widgets/home_moon_chip.dart';
import 'package:tendask/features/plus/presentation/plus_label.dart';
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

  /// A router with both destinations the chip can reach, so a tap proves which
  /// one it picked.
  GoRouter routerFor({required bool isPlus}) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: HomeMoonChipCard(isPlus: isPlus)),
      ),
      GoRoute(
        path: '/moon-calendar',
        builder: (_, _) => const Scaffold(body: Text('MOON-CALENDAR')),
      ),
      GoRoute(
        path: '/tendask-plus',
        builder: (_, _) => const Scaffold(body: Text('TENDASK-PLUS')),
      ),
    ],
  );

  /// The element-day CTA, in whichever element today happens to be.
  Finder elementCta() => find.byWidgetPredicate(
    (w) => w is Text && t.moon.day_for.values.contains(w.data),
  );

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

  testWidgets('a resume rebuilds the card (the day may have rolled over)', (
    tester,
  ) async {
    await pump(tester, const HomeMoonChipCard(isPlus: true));
    await tester.pumpAndSettle();
    expect(find.text(t.moon.calendar.title), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(t.moon.calendar.title), findsOneWidget);
  });

  testWidgets('with Tendask+ the CTA is the element day and opens the calendar',
      (tester) async {
    await pump(tester, const SizedBox.shrink(), router: routerFor(isPlus: true));
    await tester.pumpAndSettle();

    expect(find.text(t.moon.calendar.title), findsOneWidget);
    expect(elementCta(), findsOneWidget);
    expect(find.text(kPlusLabel), findsNothing);

    await tester.tap(find.byType(HomeMoonChipCard));
    await tester.pumpAndSettle();

    expect(find.text('MOON-CALENDAR'), findsOneWidget);
  });

  testWidgets('without Tendask+ the phase stays and the element day is locked',
      (tester) async {
    // The split gate of spec §6.5: the moon phase is free forever, only the
    // element day sits behind the wall.
    await pump(
      tester,
      const SizedBox.shrink(),
      router: routerFor(isPlus: false),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.moon.calendar.title), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && t.moon.phase.values.contains(w.data),
      ),
      findsOneWidget,
    );
    expect(elementCta(), findsNothing);
    expect(find.text(kPlusLabel), findsOneWidget);

    await tester.tap(find.byType(HomeMoonChipCard));
    await tester.pumpAndSettle();

    expect(find.text('TENDASK-PLUS'), findsOneWidget);
  });
}
