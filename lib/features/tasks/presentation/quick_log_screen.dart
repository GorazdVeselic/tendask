import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../i18n/translations.g.dart';

class QuickLogScreen extends StatelessWidget {
  const QuickLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: context.pop,
        ),
        title: Text(t.home.today), // placeholder title, replaced in M2.3
      ),
      body: const Center(
        child: Text('Hiter vnos — M2.3'),
      ),
    );
  }
}
