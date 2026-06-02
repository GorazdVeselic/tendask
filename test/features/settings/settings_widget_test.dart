import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/settings/application/profile_providers.dart';
import 'package:tendask/features/settings/data/profile_repository.dart';
import 'package:tendask/features/settings/presentation/settings_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('SettingsScreen', () {
    testWidgets('tapping English switches locale and persists profile.lang',
        (tester) async {
      // Always restore Slovenian so this global change doesn't leak to others.
      addTearDown(() => LocaleSettings.setLocale(AppLocale.sl));

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = ProfileRepository(db);

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            overrides: [
              profileRepositoryProvider.overrideWith((ref) => repo),
            ],
            child: const MaterialApp(home: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(LocaleSettings.currentLocale, AppLocale.sl);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(LocaleSettings.currentLocale, AppLocale.en);

      // setLang is fire-and-forget; let it settle on the real event loop.
      await tester.runAsync(() async {
        expect(await repo.getLang(), 'en');
      });
    });
  });
}
