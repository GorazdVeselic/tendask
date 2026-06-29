import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry/sentry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/theme/theme_mode_controller.dart';
import 'app/theme/theme_palette_controller.dart';
import 'core/auth/auth_service.dart';
import 'core/config.dart';
import 'core/database/database_provider.dart';
import 'core/database/seed_service.dart';
import 'core/local_prefs/local_prefs.dart';
import 'core/notifications/notification_service.dart';
import 'core/sync/sync_coordinator.dart';
import 'features/areas/application/areas_providers.dart';
import 'features/areas/data/garden_seed_service.dart';
import 'features/notifications/application/journal_nudge_coordinator.dart';
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
  // runZonedGuarded captures uncaught async errors during the whole run;
  // framework + platform errors are forwarded from inside _bootstrap. Binding +
  // Sentry init run INSIDE the zone, before _bootstrap, so they share the zone
  // that later calls runApp (a different zone triggers Flutter's mismatch error).
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Tag every event with the build that produced it (e.g. invalid_icon was a
    // vc5-only bug) — the pure-Dart SDK does not auto-detect the release, so we
    // read it from the installed package: "app.tendask@1.0.0+6".
    final info = await PackageInfo.fromPlatform();
    await Sentry.init((options) {
      options.dsn = kSentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.release =
          '${info.packageName}@${info.version}+${info.buildNumber}';
    });
    await _bootstrap();
  }, (error, stack) {
    unawaited(Sentry.captureException(error, stackTrace: stack));
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log the active backend so a debug run can't silently hit the wrong one
  // (staging vs production). debugPrint is stripped from release builds.
  debugPrint(
    'ENV: $kEnvLabel'
    '${kSupabaseUrl.isEmpty ? '' : ' — SUPABASE_URL=$kSupabaseUrl'}',
  );

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

  // Seed the default "garden" area once per device (FR-9), named in the now-set
  // language. Offline-safe (a pure local write) — it is created owned by `local`
  // and settled on sign-in by reconcileDefaultGarden, so the first cloud sync
  // never pushes a duplicate. One-shot via a local flag (a deleted garden stays
  // gone); the per-account guard that survives reinstall lives in the profile.
  //
  // Unlike the catalog seed, the default garden is NOT essential to booting: a
  // DB hiccup here must never black-screen the app. Degrade gracefully — on
  // failure the flag stays unset (transaction rolled back), so a later launch
  // retries.
  try {
    await GardenSeedService(
      container.read(databaseProvider),
      container.read(areasRepositoryProvider),
      container.read(localPrefsProvider),
    ).seedDefaultIfNeeded(name: t.areas.default_garden_name);
  } catch (error, stack) {
    debugPrint('Default garden seed failed (non-fatal): $error');
    if (kSentryDsn.isNotEmpty) {
      unawaited(Sentry.captureException(error, stackTrace: stack));
    }
  }

  // Start the background sync coordinator: a first cycle now (claim + push +
  // pull when signed in; catalog always) plus reconnect/periodic/push-on-save
  // triggers. Guests stay local (no session) — sync activates on sign-in.
  // Fire-and-forget — never blocks first paint; offline retries on a later trigger.
  unawaited(container.read(syncCoordinatorProvider.notifier).start());

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

    // Arm the re-engagement journal nudge (FR-16): a local dead-man's-switch that
    // app opens / writes push forward and only fires after the user goes quiet.
    container.read(journalNudgeCoordinatorProvider.notifier).start();
  } catch (error, stack) {
    debugPrint('Notification bootstrap failed (non-fatal): $error');
    if (kSentryDsn.isNotEmpty) {
      unawaited(Sentry.captureException(error, stackTrace: stack));
    }
  }

  // First-run gating (M7.2): show the onboarding intro until the user passes it.
  final localPrefs = container.read(localPrefsProvider);
  final onboardingSeen = await localPrefs.onboardingSeen();

  final String target;
  if (!onboardingSeen) {
    target = '/onboarding';
  } else if (launchTaskId != null) {
    target = '/tasks/$launchTaskId';
  } else {
    // Resume an interrupted email sign-in (code sent, app closed before verify)
    // on the code step — otherwise the relaunch silently lands in guest mode.
    // Consume-once: an abandoned attempt falls back to home on the next launch.
    final pendingEmail = container.read(authServiceProvider).hasSession
        ? null
        : await localPrefs.pendingSignInEmail();
    if (pendingEmail != null && pendingEmail.isNotEmpty) {
      await localPrefs.clearPendingSignInEmail();
      target = '/login-email?email=${Uri.encodeComponent(pendingEmail)}';
    } else {
      target = '/home';
    }
  }

  // Resolve the saved theme mode + colour palette before first paint so the app
  // opens in the chosen theme without a flash (same container backs runApp).
  await container.read(themeModeControllerProvider.future);
  await container.read(themePaletteControllerProvider.future);

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
