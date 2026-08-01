import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/notifications/notification_service.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/features/moon/application/garden_elements_provider.dart';
import 'package:tendask/features/moon/application/moon_hint_coordinator.dart';
import 'package:tendask/features/moon/application/moon_settings_controller.dart';
import 'package:tendask/features/settings/application/profile_providers.dart';
import 'package:tendask/features/settings/data/profile_repository.dart';
import 'package:tendask/i18n/translations.g.dart';

import '../../support/fake_notification_service.dart';

/// Same anchor as the schedule tests: over the following week the sidereal
/// calendar gives three root days (7–9 Aug) and a new moon on the 12th.
final _from = DateTime(2026, 8, 6, 9);

const _optIn = NotificationSettings(moonHintEnabled: true);

typedef _Env = ({
  ProviderContainer container,
  AppDatabase db,
  ProfileRepository profileRepo,
  FakeNotificationService notif,
});

Future<_Env> _setup({
  NotificationSettings settings = _optIn,
  Set<BiodynamicElement> garden = const {BiodynamicElement.root},
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final profileRepo = ProfileRepository(db);
  await profileRepo.setNotificationSettings(kLocalUserId, settings);
  final notif = FakeNotificationService();

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(notif),
      authServiceProvider.overrideWithValue(AuthService(null)),
      profileRepositoryProvider.overrideWithValue(profileRepo),
      // The garden derives from two drift streams and the catalog; what the
      // hint cares about is only the resulting element set.
      gardenElementsProvider.overrideWithValue(garden),
    ],
  );
  // LIFO: dispose the container (cancels the coordinator's profile
  // subscription) before closing the database.
  addTearDown(() => db.close());
  addTearDown(container.dispose);
  return (container: container, db: db, profileRepo: profileRepo, notif: notif);
}

MoonHintCoordinator _coordinator(_Env env) =>
    env.container.read(moonHintCoordinatorProvider.notifier);

String _titleFor(BiodynamicElement element) =>
    t.moon.hint.title(day: t.moon.day_for[element.name]!);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    LocaleSettings.setLocale(AppLocale.sl);
  });

  test('while the calendar is dark, arming never reaches the OS queue', () async {
    // The gate the production entry points carry: nothing was ever scheduled,
    // so the coordinator must not even cancel. T7 is what flips this.
    expect(kMoonCalendarEnabled, isFalse);
    final env = await _setup();

    _coordinator(env).start();
    await pumpEventQueue(times: 30);

    expect(env.notif.cancelled, isEmpty);
    expect(env.notif.scheduledNudges, isEmpty);
  });

  test('opt-in: clears the reserved ids first, then arms the plan in order',
      () async {
    final env = await _setup();

    await _coordinator(env).armHints(_from);

    // Cleared first, so a system switch or an opt-out can never leave a stale
    // hint behind.
    expect(env.notif.cancelled, containsAll(kMoonHintNotificationIds));
    expect(env.notif.scheduledNudges, kMoonHintNotificationIds.take(3));
    expect(env.notif.nudgeTimes, [
      DateTime(2026, 8, 6, kMoonHintHour),
      DateTime(2026, 8, 7, kMoonHintHour),
      DateTime(2026, 8, 8, kMoonHintHour),
    ]);
    expect(
      env.notif.nudgeTitles,
      everyElement(_titleFor(BiodynamicElement.root)),
    );
    expect(
      env.notif.nudgeBodies,
      everyElement(t.moon.activity[BiodynamicElement.root.name]!),
    );
  });

  test('opt-out clears the ids and arms nothing', () async {
    final env = await _setup(settings: const NotificationSettings());

    await _coordinator(env).armHints(_from);

    expect(env.notif.cancelled, containsAll(kMoonHintNotificationIds));
    expect(env.notif.scheduledNudges, isEmpty);
  });

  test('the calendar switch silences the hint too', () async {
    final env = await _setup();
    await env.container
        .read(moonSettingsControllerProvider.notifier)
        .setEnabled(false);

    await _coordinator(env).armHints(_from);

    expect(env.notif.cancelled, containsAll(kMoonHintNotificationIds));
    expect(env.notif.scheduledNudges, isEmpty);
  });

  test('an empty garden stays silent', () async {
    final env = await _setup(garden: const {});

    await _coordinator(env).armHints(_from);

    expect(env.notif.scheduledNudges, isEmpty);
  });

  test('the new moon replaces the element activity in the body', () async {
    final env = await _setup(garden: const {BiodynamicElement.leaf});

    await _coordinator(env).armHints(_from);

    // 12 Aug 2026 carries the new moon; the leaf garden hears about that day.
    expect(env.notif.nudgeTimes.single, DateTime(2026, 8, 11, kMoonHintHour));
    expect(env.notif.nudgeBodies.single, t.moon.activity_new_moon);
  });

  test('the copy is re-derived from the current system, never frozen', () async {
    final env = await _setup(garden: BiodynamicElement.values.toSet());

    await _coordinator(env).armHints(_from);
    final sidereal = [...env.notif.nudgeTitles];

    await env.container
        .read(moonSettingsControllerProvider.notifier)
        .setSystem(CalendarSystem.tropical);
    await _coordinator(env).armHints(_from);
    final tropical = env.notif.nudgeTitles.sublist(sidereal.length);

    // Same days, different zodiac: 8 Aug is a root day sidereally and a flower
    // day tropically, and the notification says so on the second arming.
    expect(sidereal[1], _titleFor(BiodynamicElement.root));
    expect(tropical[1], _titleFor(BiodynamicElement.flower));
  });
}
