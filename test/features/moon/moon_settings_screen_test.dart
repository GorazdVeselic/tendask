import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/features/moon/application/moon_settings_controller.dart';
import 'package:tendask/features/moon/presentation/moon_settings_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Simulates a failed prefs load so the screen's error branch is reachable.
class _FailingController extends MoonSettingsController {
  @override
  Future<MoonSettings> build() async => throw StateError('boom');
}

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

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: const MaterialApp(
            home: MoonSettingsScreen(),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the system segment switches every moon screen and persists', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text(t.moon.settings.system_tropical));
    await tester.pumpAndSettle();

    // One controller drives ALL moon screens (spec §11.6), so this single
    // state change is what the calendar, sheet and future chips re-read.
    expect(
      container.read(moonSettingsControllerProvider).value?.system,
      CalendarSystem.tropical,
    );
    expect(await LocalPrefsRepository(db).moonSystem(), 'tropical');
  });

  testWidgets('the main switch persists device-locally', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(t.moon.settings.enable));
    await tester.pumpAndSettle();

    expect(
      container.read(moonSettingsControllerProvider).value?.enabled,
      isFalse,
    );
    expect(await LocalPrefsRepository(db).moonCalendarEnabled(), isFalse);
  });

  testWidgets('the display sub-toggles persist device-locally', (tester) async {
    await pumpSettings(tester);
    final prefs = LocalPrefsRepository(db);

    await tester.tap(find.text(t.moon.settings.highlight_garden));
    await tester.pumpAndSettle();
    expect(await prefs.moonHighlightGarden(), isFalse);

    await tester.tap(find.text(t.moon.settings.show_in_journal));
    await tester.pumpAndSettle();
    expect(await prefs.moonShowInJournal(), isFalse);

    await tester.tap(find.text(t.moon.settings.show_astro));
    await tester.pumpAndSettle();
    expect(await prefs.moonShowAstroDetails(), isFalse);
  });

  testWidgets('a failed load shows the error message, not a stuck spinner', (
    tester,
  ) async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        moonSettingsControllerProvider.overrideWith(_FailingController.new),
      ],
    );
    await pumpSettings(tester);

    expect(find.text(t.moon.settings.load_error), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
