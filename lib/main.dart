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
