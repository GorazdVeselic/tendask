import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/app/theme/moon_colors.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/features/journal/presentation/widgets/day_cell.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';
import 'package:tendask/features/moon/presentation/widgets/journal_moon.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_phase_icon.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  testWidgets('the dark gate renders nothing, even without a ProviderScope', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(
          home: Scaffold(
            body: JournalMoonButton(),
          ),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('the moon button pushes /moon-calendar', (tester) async {
    final router = GoRouter(
      initialLocation: '/journal',
      routes: [
        GoRoute(
          path: '/journal',
          builder: (_, _) => const Scaffold(body: JournalMoonIconButton()),
        ),
        GoRoute(
          path: '/moon-calendar',
          builder: (_, _) => const Scaffold(body: Text('MOON-CALENDAR')),
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

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('MOON-CALENDAR'), findsOneWidget);
  });

  testWidgets('journalMoonDays is null on the dark path, touching no provider', (
    tester,
  ) async {
    Map<DateTime, MoonMonthDay>? result = const {};
    await tester.pumpWidget(
      // No overrides: with the flag off nothing may read prefs or the db.
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            result = journalMoonDays(ref, DateTime(2026, 8));
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(result, isNull);
  });

  Future<void> pumpCell(WidgetTester tester, {MoonMonthDay? moonDay}) async {
    await tester.pumpWidget(
      // The cell names the phase marker for screen readers, so it needs the
      // translations its host always has.
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 48,
                height: 52,
                child: DayCell(
                  day: DateTime(2026, 8, 28),
                  count: 2,
                  isToday: false,
                  selected: false,
                  onTap: () {},
                  moonDay: moonDay,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Container cellContainer(WidgetTester tester) => tester.widget<Container>(
    find
        .descendant(of: find.byType(DayCell), matching: find.byType(Container))
        .first,
  );

  testWidgets('the moon layer paints the element tone and the phase marker', (
    tester,
  ) async {
    await pumpCell(
      tester,
      moonDay: MoonMonthDay(
        date: DateTime(2026, 8, 28),
        element: BiodynamicElement.fruit,
        principalPhase: MoonPhase.fullMoon,
      ),
    );

    expect(find.byType(MoonPhaseIcon), findsOneWidget);
    final decoration = cellContainer(tester).decoration! as BoxDecoration;
    expect(decoration.color, moonColorsLight.fruitSoft);
  });

  testWidgets('without moon data the cell stays moonless', (tester) async {
    await pumpCell(tester);

    expect(find.byType(MoonPhaseIcon), findsNothing);
    final decoration = cellContainer(tester).decoration! as BoxDecoration;
    expect(decoration.color, isNot(moonColorsLight.fruitSoft));
  });
}
