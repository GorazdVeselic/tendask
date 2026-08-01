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

  test('display sub-toggles default to on when unset', () async {
    final settings = await container.read(
      moonSettingsControllerProvider.future,
    );
    expect(settings.highlightGarden, isTrue);
    expect(settings.showInJournal, isTrue);
    expect(settings.showAstroDetails, isTrue);
  });

  test('setShowInJournal updates state and persists device-locally', () async {
    await container
        .read(moonSettingsControllerProvider.notifier)
        .setShowInJournal(false);

    expect(
      container.read(moonSettingsControllerProvider).value?.showInJournal,
      isFalse,
    );
    expect(
      await container.read(localPrefsProvider).moonShowInJournal(),
      isFalse,
    );
  });

  test('setShowAstroDetails updates state and persists device-locally',
      () async {
    await container
        .read(moonSettingsControllerProvider.notifier)
        .setShowAstroDetails(false);

    expect(
      container.read(moonSettingsControllerProvider).value?.showAstroDetails,
      isFalse,
    );
    expect(
      await container.read(localPrefsProvider).moonShowAstroDetails(),
      isFalse,
    );
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

  test('setEnabled(false) survives a rebuild (persisted, not just state)',
      () async {
    await container
        .read(moonSettingsControllerProvider.notifier)
        .setEnabled(false);
    container.invalidate(moonSettingsControllerProvider);

    final settings = await container.read(
      moonSettingsControllerProvider.future,
    );
    expect(settings.enabled, isFalse);
  });

  test('an unknown stored system falls back to sidereal', () async {
    await container.read(localPrefsProvider).setMoonSystem('draconic');
    container.invalidate(moonSettingsControllerProvider);

    final settings = await container.read(
      moonSettingsControllerProvider.future,
    );
    expect(settings.system, CalendarSystem.sidereal);
  });

  test('keepAlive: the bootstrap warm-up survives without listeners', () async {
    // The provider is read once in bootstrap and then has NO listener until
    // the first moon UI subscribes — with autoDispose it would be dropped
    // right after the read and the warm-up would be pointless (the Home chip
    // would flash through AsyncLoading again).
    expect(moonSettingsControllerProvider.isAutoDispose, isFalse);

    await container.read(moonSettingsControllerProvider.future);
    await container.pump();
    expect(
      container.read(moonSettingsControllerProvider).hasValue,
      isTrue,
    );
  });
}
