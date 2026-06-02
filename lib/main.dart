import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
import 'i18n/translations.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.useDeviceLocale();

  final container = ProviderContainer();
  await SeedService(container.read(databaseProvider)).runIfNeeded();

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: const TendaskApp(),
      ),
    ),
  );
}
