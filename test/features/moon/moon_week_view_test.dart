import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';
import 'package:tendask/features/moon/presentation/moon_text.dart';
import 'package:tendask/features/moon/presentation/moon_week_view.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_phase_icon.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> pumpWeek(WidgetTester tester, DateTime weekStart) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: MoonWeekView(
                weekStart: weekStart,
                starred: const <BiodynamicElement>{},
                onPrev: () {},
                onNext: () {},
              ),
            ),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The agenda must always show seven rows: the month grid it reads carries
  /// exactly six leading days, so a week ending on the 1st sits on that edge
  /// and an off-by-one there would drop rows without any error.
  /// Every day of the week must have its own row — a day the month grid does
  /// not reach used to be skipped silently, leaving a hole instead of an error.
  void expectSevenRows(WidgetTester tester, DateTime weekStart) {
    for (var i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      expect(find.text('${date.day}'), findsOneWidget, reason: '$date');
    }
    expect(
      find.byType(MoonPhaseIcon).evaluate().length,
      lessThanOrEqualTo(7),
      reason: 'phase markers only on event days',
    );
  }

  testWidgets('a week inside one month shows seven days', (tester) async {
    final weekStart = DateTime(2026, 8, 9);
    await pumpWeek(tester, weekStart);
    expectSevenRows(tester, weekStart);
  });

  testWidgets('a week ending on the 1st still shows all seven days', (
    tester,
  ) async {
    // 26 Jul .. 1 Aug 2026 — six days belong to the previous month, which is
    // the earliest day the August grid reaches.
    final weekStart = DateTime(2026, 7, 26);
    await pumpWeek(tester, weekStart);
    expectSevenRows(tester, weekStart);
  });

  testWidgets('a week spanning a year boundary shows all seven days', (
    tester,
  ) async {
    final weekStart = DateTime(2026, 12, 28);
    await pumpWeek(tester, weekStart);
    expectSevenRows(tester, weekStart);
  });

  testWidgets('each row names the element day of its date', (tester) async {
    final weekStart = DateTime(2026, 8, 9);
    await pumpWeek(tester, weekStart);

    for (var i = 0; i < 7; i++) {
      final date = DateTime(2026, 8, 9 + i);
      final cell = moonMonthDayFor(date, CalendarSystem.sidereal);
      expect(
        find.textContaining(sentenceCase(t.moon.day_for[cell.element.name]!)),
        findsWidgets,
        reason: '$date',
      );
    }
  });
}
