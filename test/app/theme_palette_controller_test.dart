import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/theme/theme_palette.dart';
import 'package:tendask/app/theme/theme_palette_controller.dart';
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

  test('defaults to green when unset', () async {
    final palette = await container.read(
      themePaletteControllerProvider.future,
    );
    expect(palette.id, greenPalette.id);
  });

  test('set updates state and persists device-locally', () async {
    await container.read(themePaletteControllerProvider.future);
    await container.read(themePaletteControllerProvider.notifier).set('ocean');

    expect(
      container.read(themePaletteControllerProvider).value?.id,
      'ocean',
    );
    expect(await container.read(localPrefsProvider).themePalette(), 'ocean');
  });

  test('an unknown stored value falls back to green', () async {
    await container.read(localPrefsProvider).setThemePalette('rainbow');
    container.invalidate(themePaletteControllerProvider);

    final palette = await container.read(
      themePaletteControllerProvider.future,
    );
    expect(palette.id, greenPalette.id);
  });
}
