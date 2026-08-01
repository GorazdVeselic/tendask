import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/date_format.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_day_badge.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/when_step.dart';
import 'package:tendask/i18n/translations.g.dart';

/// First August 2026 day with an element transition (sidereal).
DateTime _transitionDate() {
  for (var d = 2; d < 26; d++) {
    final date = DateTime(2026, 8, d);
    if (dayFor(date, CalendarSystem.sidereal).transitionAt != null) return date;
  }
  throw StateError('no transition day in Aug 2026');
}

void main() {
  testWidgets('the dark gate renders nothing and needs no ProviderScope', (
    tester,
  ) async {
    // Locks the design constraint: host steps (when-step) are Riverpod-free
    // and their tests pump without a scope — the badge must not require one
    // while kMoonCalendarEnabled is false.
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: MoonDayBadge(date: DateTime(2026, 8, 2))),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('the when-step mounts the badge and stays ProviderScope-free', (
    tester,
  ) async {
    // Pins both halves of the wiring: the badge really is in its host (a dark
    // feature is invisible, so nothing else would notice it being dropped),
    // and the host tree still pumps without a scope.
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: WhenStepBody(
              date: DateTime(2026, 8, 2, 9),
              status: TaskStatus.waiting,
              recurrence: null,
              onSetDate: (_) {},
              onSetStatus: (_) {},
              onSetRecurrence: (_, _) {},
            ),
          ),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MoonDayBadge), findsOneWidget);
    expect(find.byType(MoonDayBadgeRow), findsNothing);
  });

  testWidgets('the row shows the day label with the transition hour', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final date = _transitionDate();
    final day = dayFor(date, CalendarSystem.sidereal);
    final cell = moonMonthDayFor(date, CalendarSystem.sidereal);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: TranslationProvider(
          child: MaterialApp(
            home: Scaffold(body: MoonDayBadgeRow(date: date)),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining(t.moon.day_for[cell.element.name]!),
      findsOneWidget,
    );
    // The transitionAt is non-null by construction of _transitionDate.
    expect(
      find.textContaining(formatHm(day.transitionAt!)),
      findsOneWidget,
    );
  });
}
