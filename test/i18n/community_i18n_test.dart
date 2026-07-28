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
///
/// The anti-steering check covers `suggestions.community.*` too (O6): those
/// strings ride the free Home band, far from the "never tells you what to do"
/// explainer, which makes them the easiest place to slip a nudge back in.
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

  /// Everything the anti-steering rule covers: the Okolica screens plus the
  /// engine's community message, which lands on the free Home band.
  final steerable = {
    for (final l in ['en', 'sl', 'de'])
      l: {
        ...community[l]!,
        ...flatten(
          (load(l)['suggestions'] as Map<String, dynamic>)['community']
              as Map<String, dynamic>,
          'suggestions.community',
        ),
      },
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

  test('the free band states no share of the neighbourhood', () {
    // O6: a percentage without its sample size and first-season caveat is a
    // number with no denominator (§7.7), and both of those live on the Plus
    // detail screen. P4 took this framing off the paid cards; the free band
    // must not bring it back through the side door.
    for (final locale in ['en', 'sl', 'de']) {
      steerable[locale]!.forEach((key, value) {
        if (!key.startsWith('suggestions.community.')) return;
        expect(
          value.contains('%') || value.contains('{percent}'),
          isFalse,
          reason: '$locale $key names a share: $value',
        );
      });
    }
  });

  test('the nav label exists in every locale', () {
    for (final l in ['en', 'sl', 'de']) {
      expect((load(l)['nav'] as Map<String, dynamic>)['community'], isNotNull);
    }
  });

  test('no community string steers the user to a purchase', () {
    // Currency and links: plain substrings, they cannot appear innocently.
    // ('$' alone would hit slang's own '$n' placeholder, so a dollar only
    // counts as money when a number follows it.)
    const symbols = ['€', 'http', 'www.', '.com', '.si/'];
    final dollarAmount = RegExp(r'\$\s*\d');
    // Buy/try wording in the three shipped languages, matched at a word START so
    // a stem still catches its inflections ('naročnin' → 'naročnina'). Entries
    // whose stem also opens an innocent word carry their own guard, because a
    // word start alone does not: 'eur' opens German 'eurer' (= your) and 'abo'
    // opens English 'about'.
    const words = [
      r'eur\b', // the ISO code, not the start of a longer word
      'euro(?!p)', // euro/euros — but not Europa
      'evro(?!p)', // evro/evrov — but not Evropa
      'price',
      'cost',
      'cena',
      'ceno',
      'ceni',
      'cenik',
      'preis',
      'buy',
      'purchase',
      'kupi',
      'nakup',
      'kaufen',
      'subscription',
      'naročnin',
      'abonn', // Abonnement / abonnieren
      'abonma',
      'trial',
      'preizkus',
      'testversion',
      'gratis',
      'kostenlos',
    ];
    final wordPattern = RegExp(r'\b(' + words.join('|') + r')', unicode: true);

    steerable.forEach((locale, strings) {
      strings.forEach((key, value) {
        final text = value.toLowerCase();
        for (final symbol in symbols) {
          expect(
            text.contains(symbol),
            isFalse,
            reason: '$locale $key contains "$symbol": $value',
          );
        }
        expect(
          dollarAmount.hasMatch(text),
          isFalse,
          reason: '$locale $key names a price: $value',
        );
        final hit = wordPattern.firstMatch(text);
        expect(
          hit,
          isNull,
          reason: '$locale $key contains "${hit?.group(1)}": $value',
        );
      });
    });
  });
}
