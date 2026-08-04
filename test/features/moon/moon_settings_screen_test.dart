import 'dart:async';

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

/// Holds the grant check open, so the gap between the tap and the stored value
/// is observable in a test the way it is on a device.
class _SlowNotificationService extends FakeNotificationService {
  _SlowNotificationService(this.gate);

  final Future<void> gate;

  @override
  Future<bool> areNotificationsEnabled() async {
    await gate;
    return super.areNotificationsEnabled();
  }
}

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
        // Every row here configures a walled surface (T6.6), so the default is
        // an entitled user; the free showroom has its own test.
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

  testWidgets('the chosen system explains itself', (tester) async {
    await pumpSettings(tester);

    expect(find.text(t.moon.settings.system_help_sidereal), findsOneWidget);
    expect(find.text(t.moon.settings.system_help_tropical), findsNothing);

    await tester.tap(find.text(t.moon.settings.system_tropical));
    await tester.pumpAndSettle();

    expect(find.text(t.moon.settings.system_help_tropical), findsOneWidget);
    expect(find.text(t.moon.settings.system_help_sidereal), findsNothing);
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

    await tester.tap(find.text(t.moon.settings.show_element_labels));
    await tester.pumpAndSettle();
    expect(await prefs.moonShowElementLabels(), isFalse);
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

  testWidgets('the hint switch moves with the finger, not with the write', (
    tester,
  ) async {
    // It asks the OS about the grant and then travels through the profile table
    // and back out of its stream; on the device that lagged the tap by about a
    // second. The gate below stands in for that delay.
    final gate = Completer<void>();
    final slow = _SlowNotificationService(gate.future);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(slow),
        plusProvider.overrideWith((ref) => _plus(active: true)),
      ],
    );
    await pumpSettings(tester);
    final hintRow = find.ancestor(
      of: find.text(t.moon.settings.hint),
      matching: find.byType(SwitchListTile),
    );

    await tester.tap(find.text(t.moon.settings.hint));
    await tester.pump();
    expect(tester.widget<SwitchListTile>(hintRow).value, isTrue);

    gate.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(hintRow).value, isTrue);
    final stored = await ProfileRepository(
      db,
    ).notificationSettings(kLocalUserId);
    expect(stored.moonHintEnabled, isTrue);
  });


  testWidgets('without Tendask+ the screen is a disabled showroom', (
    tester,
  ) async {
    // Reachable without a licence (via /tendask-plus): everything is visible so
    // the reader sees what the licence brings, but nothing can be changed.
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notif),
        plusProvider.overrideWith((ref) => _plus(active: false)),
      ],
    );
    await pumpSettings(tester);

    // SectionLabel renders its text uppercase.
    expect(
      find.text(t.moon.settings.system_label.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(t.moon.settings.about_title), findsOneWidget);

    for (final title in [
      t.moon.settings.hint,
      t.moon.settings.highlight_garden,
      t.moon.settings.show_in_journal,
      t.moon.settings.show_astro,
      t.moon.settings.show_element_labels,
    ]) {
      final row = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(title),
          matching: find.byType(SwitchListTile),
        ),
      );
      // Defaults, not the user's own state: all five on, all five dead.
      expect(row.value, isTrue, reason: title);
      expect(row.onChanged, isNull, reason: title);
    }

    expect(
      tester
          .widget<SegmentedButton<CalendarSystem>>(
            find.byType(SegmentedButton<CalendarSystem>),
          )
          .onSelectionChanged,
      isNull,
    );
    expect(find.text(t.moon.settings.system_help_sidereal), findsOneWidget);
  });

  testWidgets('the showroom paints defaults, not what the user stored', (
    tester,
  ) async {
    await LocalPrefsRepository(db).setMoonSystem('tropical');
    await LocalPrefsRepository(db).setMoonShowInJournal(false);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notif),
        plusProvider.overrideWith((ref) => _plus(active: false)),
      ],
    );
    await pumpSettings(tester);

    expect(find.text(t.moon.settings.system_help_sidereal), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(
            find.ancestor(
              of: find.text(t.moon.settings.show_in_journal),
              matching: find.byType(SwitchListTile),
            ),
          )
          .value,
      isTrue,
    );
    // Nothing was written back: the stored settings survive the visit.
    expect(await LocalPrefsRepository(db).moonSystem(), 'tropical');
    expect(await LocalPrefsRepository(db).moonShowInJournal(), isFalse);
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
