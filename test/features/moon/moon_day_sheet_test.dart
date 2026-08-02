import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/date_format.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';
import 'package:tendask/features/moon/presentation/moon_day_sheet.dart';
import 'package:tendask/i18n/translations.g.dart';

/// The branches of the day sheet that no screen test reaches, because the
/// calendar only ever opens "today's month": the new-moon copy, the
/// favorable/unfavorable verdict, and the midnight-sliver wording.
const _system = CalendarSystem.sidereal;

DateTime _firstDayWhere(bool Function(BiodynamicDay day, DateTime date) test) {
  for (var d = DateTime(2026); d.year == 2026; d = addDays(d, 1)) {
    if (test(dayFor(d, _system), d)) return d;
  }
  throw StateError('no matching day in 2026');
}

/// A day whose element changes inside the sliver window — the calendar hands
/// the whole day to the new element, so the astro block must speak of "since".
DateTime _sliverDate() => _firstDayWhere(
  (day, date) =>
      day.transitionAt != null &&
      day.transitionAt!.difference(date) < kMoonMidnightSliverWindow,
);

/// A day with an ordinary transition (well past the sliver window).
DateTime _transitionDate() => _firstDayWhere(
  (day, date) =>
      day.transitionAt != null &&
      day.transitionAt!.difference(date) > const Duration(hours: 6),
);

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

  Future<void> openSheet(WidgetTester tester, DateTime date) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => showMoonDaySheet(context, date),
                    child: const Text('OPEN'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
  }

  /// The division the Moon enters after a transition — prograde, so the next
  /// one in ecliptic order (same rule the sheet uses).
  String nextSignLabel(BiodynamicDay day) =>
      t.moon.sign[ZodiacSign
          .values[(day.sign.index + 1) % ZodiacSign.values.length]
          .name]!;

  testWidgets('a new moon day replaces the element rows with its own copy', (
    tester,
  ) async {
    // 12 Aug 2026: new moon (and an eclipse, hence unfavorable).
    await openSheet(tester, DateTime(2026, 8, 12));

    expect(find.text(t.moon.activity_new_moon), findsOneWidget);
    final cell = moonMonthDayFor(DateTime(2026, 8, 12), _system);
    expect(
      find.text(t.moon.activity[cell.element.name]!),
      findsNothing,
      reason: 'the element activity yields to the new-moon copy',
    );
  });

  testWidgets('an unfavorable day warns', (tester) async {
    final unfavorable = t.moon.sheet
        .unfavorable(b: (s) => TextSpan(text: s))
        .toPlainText();

    // 12 Aug 2026: the new moon is a total solar eclipse (fixture T1.10).
    await openSheet(tester, DateTime(2026, 8, 12));

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.textContaining(unfavorable), findsOneWidget);
  });

  testWidgets('a favorable day gets the calm verdict', (tester) async {
    final favorable = t.moon.sheet
        .favorable(b: (s) => TextSpan(text: s))
        .toPlainText();

    await openSheet(tester, DateTime(2026, 8, 15));

    expect(find.textContaining(favorable), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('a midnight sliver reads "since HH:MM", agreeing with the hero', (
    tester,
  ) async {
    final date = _sliverDate();
    final day = dayFor(date, _system);
    final cell = moonMonthDayFor(date, _system);
    await openSheet(tester, date);

    // Rich text never matches find.text — compare the flattened span.
    final since = t.moon.sheet
        .in_constellation_since(
          time: TextSpan(text: formatHm(day.transitionAt!)),
          sign: TextSpan(text: nextSignLabel(day)),
          // The element the calendar labels the day with, i.e. what the hero
          // says — the two blocks used to contradict each other here.
          day: TextSpan(text: t.moon.day_for[cell.element.name]!),
        )
        .toPlainText();

    expect(find.textContaining(since), findsOneWidget);
  });

  testWidgets('an ordinary transition day keeps the "at HH:MM" wording', (
    tester,
  ) async {
    final date = _transitionDate();
    final day = dayFor(date, _system);
    final cell = moonMonthDayFor(date, _system);
    await openSheet(tester, date);

    final transition = t.moon.sheet
        .transition(
          time: TextSpan(text: formatHm(day.transitionAt!)),
          sign: TextSpan(text: nextSignLabel(day)),
          day: TextSpan(text: t.moon.day_for[cell.secondaryElement!.name]!),
        )
        .toPlainText();

    expect(find.textContaining(transition), findsOneWidget);
  });
}
