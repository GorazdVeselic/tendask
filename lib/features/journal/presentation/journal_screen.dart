import 'package:flutter/material.dart';
import '../../../i18n/translations.g.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(context.t.nav.journal)),
    );
  }
}
