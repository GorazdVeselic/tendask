import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';

/// The M11 gates decide whether an unfinished feature reaches a shipped APK, so
/// "off" has to be the state you get when nobody did anything. A build only
/// turns them on by passing the define — see docs/deploy-runbook.md.
void main() {
  test('the M11 gates are off unless the build says otherwise', () {
    // No --dart-define under `flutter test`, so this is the default a
    // production build gets too.
    expect(kSuggestionsEnabled, isFalse);
    expect(kCommunityEnabled, isFalse);
  });

  test('the production defines template turns nothing on', () {
    // The real dart_defines.json is gitignored; the template is what a new
    // machine copies, and it must not carry a live feature into a Play build.
    final template =
        jsonDecode(File('dart_defines.example.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(template.containsKey('SUGGESTIONS_ENABLED'), isFalse);
    expect(template.containsKey('COMMUNITY_ENABLED'), isFalse);
  });

  test('the staging defines template turns both on', () {
    // Staging is where M11 is exercised; if this drifts, a staging build goes
    // dark and the tester debugs an app that was never enabled.
    final template =
        jsonDecode(File('dart_defines.staging.example.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(template['SUGGESTIONS_ENABLED'], 'true');
    expect(template['COMMUNITY_ENABLED'], 'true');
  });
}
