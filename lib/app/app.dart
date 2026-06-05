import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../i18n/translations.g.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TendaskApp extends StatefulWidget {
  const TendaskApp({super.key, this.initialLocation = '/home'});

  /// Resolved once at startup from first-run state (M7.2): '/onboarding' or '/home'.
  final String initialLocation;

  @override
  State<TendaskApp> createState() => _TendaskAppState();
}

class _TendaskAppState extends State<TendaskApp> {
  // Built once so navigation state survives rebuilds.
  late final _router = createAppRouter(initialLocation: widget.initialLocation);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tendask',
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
