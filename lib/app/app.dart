import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TendaskApp extends ConsumerWidget {
  const TendaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(appNameProvider);
    return MaterialApp.router(
      title: name,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
