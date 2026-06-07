import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/auth/auth_service.dart';
import 'core/config.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
import 'core/local_prefs/local_prefs.dart';
import 'core/notifications/notification_service.dart';
import 'core/sync/sync_coordinator.dart';
import 'features/notifications/application/reminder_coordinator.dart';
import 'features/settings/application/profile_providers.dart';
import 'i18n/plural_resolvers.dart';
import 'i18n/translations.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash/error monitoring (M9.1). When no DSN is configured (dev without the
  // key, or fully offline builds) Sentry stays off and the app boots normally —
  // same offline-first pattern as Supabase. Running the whole bootstrap inside
  // the appRunner zone means startup errors are captured too, not just runtime.
  if (kSentryDsn.isEmpty) {
    await _bootstrap();
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = kSentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
    },
    appRunner: _bootstrap,
  );
}

Future<void> _bootstrap() async {
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

  // Start the background sync coordinator: a first cycle now (claim + push +
  // pull when signed in; catalog always) plus reconnect/periodic/push-on-save
  // triggers. Guests stay local (no session) — sync activates on sign-in.
  // Fire-and-forget — never blocks first paint; offline retries on a later trigger.
  container.read(syncCoordinatorProvider.notifier).start();

  // Local notifications (M8): init the plugin (timezone + plugin), needed to
  // resolve a cold-start deep-link below. The permission prompt stays deferred to
  // the priming screen (21), never at startup. If a tapped reminder launched the
  // app (M8.3), open its task detail instead of home.
  final launchTaskId =
      await container.read(notificationServiceProvider).initialPayload();

  // Reconcile OS reminders with the task_reminder rows now, then reactively on
  // every task/reminder change (M8.2). Fire-and-forget.
  container.read(reminderCoordinatorProvider.notifier).start();

  // First-run gating (M7.2): show the onboarding intro until the user passes it.
  final onboardingSeen = await container.read(localPrefsProvider).onboardingSeen();

  final String initialLocation;
  if (!onboardingSeen) {
    initialLocation = '/onboarding';
  } else if (launchTaskId != null) {
    initialLocation = '/tasks/$launchTaskId';
  } else {
    initialLocation = '/home';
  }

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: TendaskApp(initialLocation: initialLocation),
      ),
    ),
  );
}
