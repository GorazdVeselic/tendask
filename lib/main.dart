import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/local_row_claim.dart';
import 'core/config.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
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

  // Bring up the anonymous session in the background — never block first paint.
  unawaited(_bootstrapSession(container));

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: const TendaskApp(),
      ),
    ),
  );
}

/// Signs in anonymously so sync has a real auth.uid(), then claims any rows
/// created locally before the session existed. Offline-first: sign-in fails
/// gracefully when offline (no-op), and M6.4 retries on reconnect.
Future<void> _bootstrapSession(ProviderContainer container) async {
  final auth = container.read(authServiceProvider);
  if (!auth.hasSession) await auth.ensureAnonymousSession();
  if (auth.hasSession) {
    await claimLocalRows(container.read(databaseProvider), auth.userId);
  }
}
