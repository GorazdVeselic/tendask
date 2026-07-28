import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Slovene only: `en` has no grammatical gender to get wrong and German past
/// participles ("hast du geerntet") do not inflect for it either. Slovene does
/// — and every masculine form the app printed told half its readers the app was
/// not written for them ("Dobrodošel", "kako si se odzval", "Koliko si pobral").
///
/// The rule is not "avoid these words" but "do not address the reader in a form
/// that carries gender": reach for a noun ("Koliko pridelka?"), an adverb
/// ("zgodaj"), or the present tense ("ki ga nastaviš") instead.
void main() {
  final root =
      jsonDecode(File('lib/i18n/sl.i18n.json').readAsStringSync())
          as Map<String, dynamic>;

  final strings = <String, String>{};
  void walk(dynamic node, String path) {
    switch (node) {
      case final Map<String, dynamic> map:
        map.forEach((k, v) => walk(v, path.isEmpty ? k : '$path.$k'));
      case final String s:
        strings[path] = s;
    }
  }

  walk(root, '');

  test('sl catalog is not empty (a silent walk would pass everything)', () {
    expect(strings.length, greaterThan(500));
  });

  test('no string addresses the reader with a gendered past tense', () {
    // "si (se) odzval", "boš pobral", "si ga nastavil" — the second person plus
    // an -l participle is masculine by construction. Third-person subjects are
    // untouched: "Tendask predlagal" is the app, not the reader.
    final secondPerson = RegExp(
      r'\b(si|boš|bi)\s+(se\s+|si\s+|ga\s+|jo\s+|jih\s+|že\s+)?\w+(al|el|il|šel)\b',
      caseSensitive: false,
      unicode: true,
    );
    strings.forEach((path, text) {
      final hit = secondPerson.firstMatch(text);
      expect(hit, isNull, reason: '$path: "${hit?.group(0)}" in: $text');
    });
  });

  test('no string uses a gendered form the app has already been fixed for', () {
    // A scar list, not a style guide: every word here was shipped once. Elliptic
    // questions ("Pokosil, zalil, pognojil?") and bare adjectives ("zgoden")
    // carry no second-person marker, so the regex above cannot see them.
    final scars = RegExp(
      r'\b(dobrodošel|dobrodošla|pozdravljen|pozdravljena|pripravljen|'
      r'prepričan|odzval|odzvala|pokosil|zalil|pognojil|zgoden|pozen)\b',
      caseSensitive: false,
      unicode: true,
    );
    strings.forEach((path, text) {
      final hit = scars.firstMatch(text);
      expect(hit, isNull, reason: '$path: "${hit?.group(0)}" in: $text');
    });
  });

  test('the timing band reads as an adverb, not a masculine adjective', () {
    // The neighbouring community.detail.you_band was already neutral; the
    // one-word pill next to it was not (P10.1).
    final band = strings.entries
        .where((e) => e.key.startsWith('community.standing.band.'))
        .map((e) => e.value)
        .toList();
    expect(band, hasLength(3));
    expect(band, containsAll(['zgodaj', 'običajno', 'pozno']));
  });
}
