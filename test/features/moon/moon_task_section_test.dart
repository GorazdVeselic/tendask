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
import 'package:tendask/features/moon/presentation/moon_text.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_task_section.dart';
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
  testWidgets('the dark gate renders nothing, including the section label', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: MoonTaskSection(date: DateTime(2026, 8, 2))),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('the card shows the day, the transition tail and the footnote', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final date = _transitionDate();
    final day = dayFor(date, CalendarSystem.sidereal);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: TranslationProvider(
          child: MaterialApp(
            home: Scaffold(body: MoonTaskSectionCard(date: date)),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(sentenceCase(t.moon.day_for[day.element.name]!)),
      findsOneWidget,
    );
    // The transitionAt is non-null by construction of _transitionDate.
    expect(find.textContaining(formatHm(day.transitionAt!)), findsOneWidget);
    expect(find.text(t.moon.task_section.footnote), findsOneWidget);
  });
}
