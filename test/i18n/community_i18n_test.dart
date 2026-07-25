import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Two guards on the community (Okolica) strings.
///
/// 1. Completeness: slang falls back to the base locale silently, so a forgotten
///    sl/de key ships as English instead of failing the build.
/// 2. Anti-steering (FR-20 §3.1): Plus is bought outside the app, so no string
///    here may carry a price, a link or a call to buy/try. Breaking this risks
///    the Play listing, not just the wording.
void main() {
  Map<String, dynamic> load(String locale) =>
      jsonDecode(File('lib/i18n/$locale.i18n.json').readAsStringSync())
          as Map<String, dynamic>;

  /// Flattens a subtree to 'a.b.c' → value, so a missing leaf names itself.
  Map<String, String> flatten(Map<String, dynamic> node, [String prefix = '']) {
    final out = <String, String>{};
    node.forEach((key, value) {
      final path = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        out.addAll(flatten(value, path));
      } else {
        out[path] = value as String;
      }
    });
    return out;
  }

  final community = {
    for (final l in ['en', 'sl', 'de'])
      l: flatten(load(l)['community'] as Map<String, dynamic>),
  };

  test('every community key is translated in sl and de', () {
    for (final locale in ['sl', 'de']) {
      final missing = community['en']!.keys
          .where((k) => !community[locale]!.containsKey(k))
          .toList();
      expect(missing, isEmpty, reason: '$locale is missing: $missing');
    }
    // Slovene needs the two/few forms its plural resolver selects.
    expect(community['sl']!.keys, contains('population(n).two'));
    expect(community['sl']!.keys, contains('population(n).few'));
  });

  test('the nav label exists in every locale', () {
    for (final l in ['en', 'sl', 'de']) {
      expect((load(l)['nav'] as Map<String, dynamic>)['community'], isNotNull);
    }
  });

  test('no community string steers the user to a purchase', () {
    // Prices, links, and buy/try wording in the three shipped languages.
    const forbidden = [
      '€',
      'eur',
      'price',
      'cena',
      'ceni',
      'preis',
      'http',
      'www.',
      '.com',
      'buy',
      'kupi',
      'nakup',
      'kaufen',
      'subscri',
      'naročnin',
      'abo',
      'trial',
      'preizkus',
      'testversion',
      'gratis',
      'kostenlos',
    ];
    community.forEach((locale, strings) {
      strings.forEach((key, value) {
        final text = value.toLowerCase();
        for (final needle in forbidden) {
          expect(
            text.contains(needle),
            isFalse,
            reason: '$locale $key contains "$needle": $value',
          );
        }
      });
    });
  });
}
