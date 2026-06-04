import 'dart:async';

import 'package:tendask/i18n/plural_resolvers.dart';

/// Runs once before any test in this directory: register the sl/de plural
/// resolvers (mirrors main()), so widget tests rendering plural keys don't log
/// "Resolver not specified" and resolve the correct form.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  configurePluralResolvers();
  await testMain();
}
