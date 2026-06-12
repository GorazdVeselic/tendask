import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/fcm_handler.dart';
import '../core/notifications/notification_service.dart';
import '../i18n/translations.g.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

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
    // FCM pushes tapped while the app is in background (M11.7).
    _fcmTapSub = ref
        .read(fcmHandlerProvider)
        .suggestionTaps
        .listen(_goToSuggestion);
  }

  // Home is the suggestions' home (koncept §7.12); the band highlights the id
  // once it exists (M11.13) — until then navigating there is the whole link.
  void _goToSuggestion(String suggestionId) =>
      _router.go('/home?suggestion=$suggestionId');

  @override
  void dispose() {
    _tapSub?.cancel();
    _fcmTapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
