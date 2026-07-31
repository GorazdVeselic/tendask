import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/features/moon/application/moon_settings_controller.dart';

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

  test('defaults to enabled + sidereal when unset', () async {
    final settings = await container.read(
      moonSettingsControllerProvider.future,
    );
    expect(settings.enabled, isTrue);
    expect(settings.system, CalendarSystem.sidereal);
  });

  test('setEnabled updates state and persists device-locally', () async {
    await container
        .read(moonSettingsControllerProvider.notifier)
        .setEnabled(false);

    expect(
      container.read(moonSettingsControllerProvider).value?.enabled,
      isFalse,
    );
    expect(
      await container.read(localPrefsProvider).moonCalendarEnabled(),
      isFalse,
    );
  });

  test('setSystem updates state and persists device-locally', () async {
    await container
        .read(moonSettingsControllerProvider.notifier)
        .setSystem(CalendarSystem.tropical);

    expect(
      container.read(moonSettingsControllerProvider).value?.system,
      CalendarSystem.tropical,
    );
    expect(await container.read(localPrefsProvider).moonSystem(), 'tropical');
  });

  test('an unknown stored system falls back to sidereal', () async {
    await container.read(localPrefsProvider).setMoonSystem('draconic');
    container.invalidate(moonSettingsControllerProvider);

    final settings = await container.read(
      moonSettingsControllerProvider.future,
    );
    expect(settings.system, CalendarSystem.sidereal);
  });
}
