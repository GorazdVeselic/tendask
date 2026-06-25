import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/notification_service.dart';
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

  @override
  void initState() {
    super.initState();
    // Deep-link reminders tapped while the app is alive (M8.3); cold-start taps
    // are handled via the initial location resolved in main().
    _tapSub = ref
        .read(notificationServiceProvider)
        .taps
        .listen(
          (taskId) =>
              _router.goNamed('task-detail', pathParameters: {'id': taskId}),
        );
  }

  @override
  void dispose() {
    _tapSub?.cancel();
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
    );
  }
}
