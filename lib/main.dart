import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry/sentry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/auth/auth_service.dart';
import 'core/config.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
import 'core/local_prefs/local_prefs.dart';
import 'core/location/location_repository.dart';
import 'core/notifications/notification_service.dart';
import 'core/sync/sync_coordinator.dart';
import 'features/notifications/application/fcm_token_service.dart';
import 'features/notifications/application/reminder_coordinator.dart';
import 'features/settings/application/profile_providers.dart';
import 'i18n/plural_resolvers.dart';
import 'i18n/translations.g.dart';

void main() async {
  // Crash/error monitoring (M9.1). Pure-Dart sentry (no native build deps, so it
  // compiles on any Android toolchain). When no DSN is configured (dev without
  // the key, or fully offline builds) Sentry stays off and the app boots
  // normally — same offline-first pattern as Supabase.
  if (kSentryDsn.isEmpty) {
    await _bootstrap();
    return;
  }
  await Sentry.init((options) {
    options.dsn = kSentryDsn;
    options.environment = kReleaseMode ? 'production' : 'development';
  });
  // runZonedGuarded captures uncaught async errors during the whole run;
  // framework + platform errors are forwarded from inside _bootstrap.
  await runZonedGuarded(_bootstrap, (error, stack) {
    unawaited(Sentry.captureException(error, stackTrace: stack));
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pure-Dart sentry has no automatic Flutter integration, so forward framework
  // and platform-dispatcher errors to it (only when configured).
  if (kSentryDsn.isNotEmpty) {
    final priorOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      priorOnError?.call(details); // keep default console logging
      unawaited(
        Sentry.captureException(details.exception, stackTrace: details.stack),
      );
    };
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      unawaited(Sentry.captureException(error, stackTrace: stack));
      return false; // let the default handler run too
    };
  }

  await LocaleSettings.useDeviceLocale();
  configurePluralResolvers();

  // FCM (M11.5): Firebase reads its config from native resources
  // (google-services.json), so init works offline. FCM is only a bell — a
  // failure here must never block boot (suggestions still arrive via pull).
  try {
    await Firebase.initializeApp();
  } catch (error, stack) {
    debugPrint('Firebase bootstrap failed (non-fatal): $error');
    if (kSentryDsn.isNotEmpty) {
      unawaited(Sentry.captureException(error, stackTrace: stack));
    }
  }

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
  final savedLang = await container
      .read(profileRepositoryProvider)
      .getLang(userId);
  if (savedLang != null) await LocaleSettings.setLocaleRaw(savedLang);

  // Start the background sync coordinator: a first cycle now (claim + push +
  // pull when signed in; catalog always) plus reconnect/periodic/push-on-save
  // triggers. Guests stay local (no session) — sync activates on sign-in.
  // Fire-and-forget — never blocks first paint; offline retries on a later trigger.
  container.read(syncCoordinatorProvider.notifier).start();

  // FCM token mirror (M11.6): once signed in + notifications granted it stores
  // the registration token in the profile (the smart engine's push target).
  // listen, not read: an unlistened keepAlive provider rebuilds lazily, so the
  // auth-change re-run (sign-in after boot) would otherwise never fire.
  container.listen(fcmTokenServiceProvider, (_, _) {});

  // Silent yearly climate-profile refresh (M11.3): fills a profile left null by
  // an offline onboarding or older than a year. Fire-and-forget, never throws.
  unawaited(container.read(locationRepositoryProvider).refreshClimateIfStale(userId));

  // Local notifications (M8): init the plugin (timezone + plugin), needed to
  // resolve a cold-start deep-link below. The permission prompt stays deferred to
  // the priming screen (21), never at startup. If a tapped reminder launched the
  // app (M8.3), open its task detail instead of home.
  //
  // Notifications are NOT essential to booting: a plugin/icon/timezone failure
  // here must never prevent runApp (it would hang the app on the native splash).
  // Degrade gracefully — report and continue without the deep-link.
  String? launchTaskId;
  try {
    launchTaskId = await container
        .read(notificationServiceProvider)
        .initialPayload();

    // Reconcile OS reminders with the task_reminder rows now, then reactively on
    // every task/reminder change (M8.2). Fire-and-forget.
    container.read(reminderCoordinatorProvider.notifier).start();
  } catch (error, stack) {
    debugPrint('Notification bootstrap failed (non-fatal): $error');
    if (kSentryDsn.isNotEmpty) {
      unawaited(Sentry.captureException(error, stackTrace: stack));
    }
  }

  // First-run gating (M7.2): show the onboarding intro until the user passes it.
  final onboardingSeen = await container
      .read(localPrefsProvider)
      .onboardingSeen();

  final String target;
  if (!onboardingSeen) {
    target = '/onboarding';
  } else if (launchTaskId != null) {
    target = '/tasks/$launchTaskId';
  } else {
    target = '/home';
  }

  // Start on the branded splash (M9.2), which routes to [target] after a brief
  // readable delay.
  final initialLocation = '/splash?next=${Uri.encodeComponent(target)}';

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: TendaskApp(initialLocation: initialLocation),
      ),
    ),
  );
}
