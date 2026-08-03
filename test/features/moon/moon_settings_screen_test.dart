import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/core/notifications/notification_service.dart';
import 'package:tendask/features/moon/application/moon_settings_controller.dart';
import 'package:tendask/features/moon/presentation/moon_settings_screen.dart';
import 'package:tendask/features/plus/application/plus_provider.dart';
import 'package:tendask/features/plus/application/plus_token.dart';
import 'package:tendask/features/settings/data/profile_repository.dart';
import 'package:tendask/i18n/translations.g.dart';

import '../../support/fake_notification_service.dart';

/// Simulates a failed prefs load so the screen's error branch is reachable.
class _FailingController extends MoonSettingsController {
  @override
  Future<MoonSettings> build() async => throw StateError('boom');
}

/// The entitlement as a plain value — the signed token is exercised in
/// plus_provider_test.
Stream<PlusStatus> _plus({required bool active}) => Stream.value(
  active
      ? PlusStatus.active(until: DateTime.utc(2027))
      : const PlusStatus.none(),
);

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FakeNotificationService notif;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    notif = FakeNotificationService();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        // The 🔔 row asks the OS for the notification grant before it opts in.
        notificationServiceProvider.overrideWithValue(notif),
        // Everything below the master switch is a Tendask+ row (T6.6), so the
        // default here is an entitled user; the free screen has its own test.
        plusProvider.overrideWith((ref) => _plus(active: true)),
      ],
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

  testWidgets('the hint opt-in starts off and writes to the synced profile', (
    tester,
  ) async {
    await pumpSettings(tester);
    final hintRow = find.ancestor(
      of: find.text(t.moon.settings.hint),
      matching: find.byType(SwitchListTile),
    );

    // Off by default (decision B1) but reachable — a disabled row would mean
    // the settings never resolved.
    expect(tester.widget<SwitchListTile>(hintRow).value, isFalse);
    expect(tester.widget<SwitchListTile>(hintRow).onChanged, isNotNull);

    await tester.tap(find.text(t.moon.settings.hint));
    await tester.pumpAndSettle();

    // Unlike every other row here, this one lives in the profile, so it syncs
    // with the account instead of staying on the device.
    final settings = await ProfileRepository(
      db,
    ).notificationSettings(kLocalUserId);
    expect(settings.moonHintEnabled, isTrue);
    expect(tester.widget<SwitchListTile>(hintRow).value, isTrue);
  });

  testWidgets('without Tendask+ only the free switch and the explainer stay', (
    tester,
  ) async {
    // The screen is reachable without a licence (via /tendask-plus) so the free
    // phase chip can be switched back on; the paid rows would otherwise be
    // settings for surfaces the wall hides.
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notif),
        plusProvider.overrideWith((ref) => _plus(active: false)),
      ],
    );
    await pumpSettings(tester);

    expect(find.text(t.moon.settings.enable), findsOneWidget);
    expect(find.text(t.moon.settings.enable_sub_free), findsOneWidget);
    expect(find.text(t.moon.settings.about_title), findsOneWidget);

    expect(find.text(t.moon.settings.system_label), findsNothing);
    expect(find.text(t.moon.settings.hint), findsNothing);
    expect(find.text(t.moon.settings.highlight_garden), findsNothing);
    expect(find.text(t.moon.settings.show_in_journal), findsNothing);
    expect(find.text(t.moon.settings.show_astro), findsNothing);

    // The switch still works — that is the whole point of keeping it here.
    await tester.tap(find.text(t.moon.settings.enable));
    await tester.pumpAndSettle();
    expect(await LocalPrefsRepository(db).moonCalendarEnabled(), isFalse);
  });

  testWidgets('a failed load shows the error message, not a stuck spinner', (
    tester,
  ) async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        moonSettingsControllerProvider.overrideWith(_FailingController.new),
        plusProvider.overrideWith((ref) => _plus(active: true)),
      ],
    );
    await pumpSettings(tester);

    expect(find.text(t.moon.settings.load_error), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
