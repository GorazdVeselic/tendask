import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class TendaskApp extends ConsumerWidget {
  const TendaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(appNameProvider);
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(name),
        ),
      ),
    );
  }
}
