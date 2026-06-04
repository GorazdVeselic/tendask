import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
import 'features/settings/application/profile_providers.dart';
import 'i18n/translations.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.useDeviceLocale();
  _configurePluralResolvers();

  final container = ProviderContainer();
  await SeedService(container.read(databaseProvider)).runIfNeeded();

  // Restore the user's chosen language (offline-first: drift is the source).
  final savedLang = await container.read(profileRepositoryProvider).getLang();
  if (savedLang != null) await LocaleSettings.setLocaleRaw(savedLang);

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: const TendaskApp(),
      ),
    ),
  );
}

/// slang ships cardinal plural rules only for some languages; sl and de need an
/// explicit resolver, else plural keys fall back and pick the wrong category.
void _configurePluralResolvers() {
  // Slovene CLDR cardinal: one = n%100==1, two = n%100==2, few = n%100∈{3,4}.
  LocaleSettings.setPluralResolverSync(
    language: 'sl',
    cardinalResolver: (n, {zero, one, two, few, many, other}) {
      final mod = n.toInt() % 100;
      if (mod == 1) return one ?? other!;
      if (mod == 2) return two ?? other!;
      if (mod == 3 || mod == 4) return few ?? other!;
      return other!;
    },
  );
  LocaleSettings.setPluralResolverSync(
    language: 'de',
    cardinalResolver: (n, {zero, one, two, few, many, other}) =>
        n == 1 ? (one ?? other!) : other!,
  );
}
