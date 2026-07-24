import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../core/notifications/fcm_handler.dart';
import '../core/notifications/notification_service.dart';
import '../features/notifications/application/journal_nudge_coordinator.dart';
import '../i18n/translations.g.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';
import 'theme/theme_palette.dart';
import 'theme/theme_palette_controller.dart';

class TendaskApp extends ConsumerStatefulWidget {
  const TendaskApp({super.key, this.initialLocation = '/home'});

  /// Resolved once at startup from first-run state (M7.2): '/onboarding' or
  /// '/home', or a deep-linked '/tasks/:id' when a reminder cold-started the app.
  final String initialLocation;

  @override
  ConsumerState<TendaskApp> createState() => _TendaskAppState();
}

class _TendaskAppState extends ConsumerState<TendaskApp> {
  // Built once so navigation state survives rebuilds.
  late final _router = createAppRouter(initialLocation: widget.initialLocation);
  StreamSubscription<String>? _tapSub;
  StreamSubscription<String>? _fcmTapSub;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Deep-link notifications tapped while the app is alive (M8.3 reminders,
    // M11.7 foreground suggestions); cold-start taps are handled via the
    // initial location resolved in main().
    _tapSub = ref.read(notificationServiceProvider).taps.listen((payload) {
      final suggestionId = NotificationService.suggestionIdFromPayload(payload);
      if (suggestionId != null) {
        _goToSuggestion(suggestionId);
      } else {
        _router.goNamed('task-detail', pathParameters: {'id': payload});
      }
    });
    if (kSuggestionsEnabled) {
      // FCM pushes tapped while the app is in background (M11.7).
      _fcmTapSub = ref
          .read(fcmHandlerProvider)
          .suggestionTaps
          .listen(_goToSuggestion);
    }

    // A foreground return counts as activity: push the journal nudge forward
    // (FR-16). Cold start is covered by the coordinator's start() in main().
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          ref.read(journalNudgeCoordinatorProvider.notifier).onResume(),
    );
  }

  // Home is the suggestions' home (koncept §7.12); the band highlights the id
  // once it exists (M11.13) — until then navigating there is the whole link.
  void _goToSuggestion(String suggestionId) =>
      _router.go('/home?suggestion=$suggestionId');

  @override
  void dispose() {
    _tapSub?.cancel();
    _fcmTapSub?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warmed in bootstrap, so these are resolved on first paint (no flash).
    final themeMode =
        ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final palette =
        ref.watch(themePaletteControllerProvider).value ?? greenPalette;
    return MaterialApp.router(
      title: 'Tendask',
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(palette),
      darkTheme: AppTheme.dark(palette),
      themeMode: themeMode,
      routerConfig: _router,
      builder: _envBanner,
    );
  }

  // Dev-only environment indicator: corner banner on non-production builds so a
  // staging/offline build is never mistaken for prod. Colors are intentionally
  // non-brand (this chrome never reaches prod users).
  Widget _envBanner(BuildContext context, Widget? child) {
    final content = child ?? const SizedBox.shrink();
    if (kEnvLabel == 'production') return content;
    return Banner(
      message: kEnvLabel == 'staging' ? 'STAGING' : 'OFFLINE',
      location: BannerLocation.topEnd,
      color: kEnvLabel == 'staging' ? Colors.orange : Colors.grey,
      child: content,
    );
  }
}
