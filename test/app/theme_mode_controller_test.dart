import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/theme/theme_mode_controller.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';

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

  test('defaults to system when unset', () async {
    expect(
      await container.read(themeModeControllerProvider.future),
      ThemeMode.system,
    );
  });

  test('set updates state and persists device-locally', () async {
    await container.read(themeModeControllerProvider.future);
    await container.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);

    expect(container.read(themeModeControllerProvider).value, ThemeMode.dark);
    expect(await container.read(localPrefsProvider).themeMode(), 'dark');
  });

  test('an unknown stored value falls back to system', () async {
    await container.read(localPrefsProvider).setThemeMode('rainbow');
    container.invalidate(themeModeControllerProvider);

    expect(
      await container.read(themeModeControllerProvider.future),
      ThemeMode.system,
    );
  });
}
