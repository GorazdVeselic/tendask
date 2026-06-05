import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/auth/auth_service.dart';
import 'core/config.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
import 'core/local_prefs/local_prefs.dart';
import 'core/sync/sync_coordinator.dart';
import 'features/settings/application/profile_providers.dart';
import 'i18n/plural_resolvers.dart';
import 'i18n/translations.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.useDeviceLocale();
  configurePluralResolvers();

  // Cloud backend (M5). Skipped when unconfigured so the app still boots fully
  // offline — drift remains the source of truth regardless of Supabase.
  if (kSupabaseUrl.isNotEmpty) {
    await Supabase.initialize(
      url: kSupabaseUrl,
      publishableKey: kSupabasePublishableKey,
    );
  }

  final container = ProviderContainer();
  await SeedService(container.read(databaseProvider)).runIfNeeded();

  // Restore the user's chosen language (offline-first: drift is the source).
  final userId = container.read(authServiceProvider).userId;
  final savedLang =
      await container.read(profileRepositoryProvider).getLang(userId);
  if (savedLang != null) await LocaleSettings.setLocaleRaw(savedLang);

  // Start the background sync coordinator: a first cycle now (sign-in + claim +
  // push + pull + catalog) plus reconnect/periodic triggers. Fire-and-forget —
  // never blocks first paint; offline fails gracefully and a later trigger retries.
  container.read(syncCoordinatorProvider.notifier).start();

  // First-run gating (M7.2): show the onboarding intro until the user passes it.
  final onboardingSeen = await container.read(localPrefsProvider).onboardingSeen();

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: TendaskApp(
          initialLocation: onboardingSeen ? '/home' : '/onboarding',
        ),
      ),
    ),
  );
}
