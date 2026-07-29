import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the strings that flip when a feature flag is turned on (najdba N13).
///
/// Five places promised "soon (V2)" while the feature was already reachable on
/// a neighbouring screen. The flags are compile-time consts, so a widget test
/// can only ever render one side of the branch — this checks the catalog
/// instead: the dark string still promises the future, the live one never does.
void main() {
  Map<String, dynamic> load(String locale) =>
      jsonDecode(File('lib/i18n/$locale.i18n.json').readAsStringSync())
          as Map<String, dynamic>;

  final locales = {
    for (final l in ['en', 'sl', 'de']) l: load(l),
  };

  /// Words that promise a feature is not here yet, in the three shipped
  /// languages. 'V2' is the badge the intro used; the priming sheet wrote it as
  /// '(V2, optional)', which an exact '(V2)' match walked straight past (N27).
  final promise = RegExp(
    r'\b(soon|later|kmalu|pozneje|kasneje|demnächst|später|bald)\b|\(v2\b',
    caseSensitive: false,
    unicode: true,
  );

  String read(Map<String, dynamic> root, String path) {
    dynamic node = root;
    for (final part in path.split('.')) {
      expect(node, isA<Map<String, dynamic>>(), reason: 'missing $path');
      node = (node as Map<String, dynamic>)[part];
    }
    expect(node, isA<String>(), reason: 'missing $path');
    return node as String;
  }

  /// dark key → the key shown once its flag is on.
  ///
  /// `location.why` used to be here. FR-24 merged it with `location.why_live`
  /// into one string that names Okolica without dating it: the sentence says
  /// what the location is *for*, and a purpose does not expire when a flag is
  /// off. One key, no branch on that screen.
  const pairs = {
    'onboarding.nearby_body': 'onboarding.nearby_body_live',
    'notif_settings.type_weather_sub': 'notif_settings.type_weather_sub_live',
    'notif_settings.type_community_sub':
        'notif_settings.type_community_sub_live',
    'notif_priming.benefit_nearby': 'notif_priming.benefit_nearby_live',
  };

  test('every dark string has a live twin in all three locales', () {
    locales.forEach((locale, root) {
      pairs.forEach((dark, live) {
        expect(read(root, dark), isNotEmpty, reason: '$locale $dark');
        expect(read(root, live), isNotEmpty, reason: '$locale $live');
      });
    });
  });

  test('no live string promises the feature is still coming', () {
    locales.forEach((locale, root) {
      for (final live in pairs.values) {
        final text = read(root, live);
        final hit = promise.firstMatch(text);
        expect(
          hit,
          isNull,
          reason: '$locale $live still says "${hit?.group(0)}": $text',
        );
      }
    });
  });

  test('the dark strings do promise it — otherwise the pair is pointless', () {
    locales.forEach((locale, root) {
      for (final dark in pairs.keys) {
        expect(
          promise.hasMatch(read(root, dark)),
          isTrue,
          reason: '$locale $dark no longer marks the feature as upcoming',
        );
      }
      // The intro badge has no live twin: with Okolica on, it is not rendered.
      expect(promise.hasMatch(read(root, 'onboarding.soon_badge')), isTrue);
    });
  });
}
