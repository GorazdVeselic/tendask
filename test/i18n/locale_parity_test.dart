import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Slang falls back to the base locale for a missing key (`fallback_strategy:
/// base_locale`), so a forgotten translation ships as silent English instead of
/// a build error — `moon.finder.*` lived a whole step that way. This compares
/// the key sets of the three files directly.
///
/// Read the JSON, not the generated classes: the generator has already applied
/// the fallback by then, which is exactly what must not hide a gap.
Set<String> _keys(Map<String, dynamic> node, [String prefix = '']) {
  final keys = <String>{};
  for (final entry in node.entries) {
    final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    keys.add(path);
    final value = entry.value;
    if (value is Map<String, dynamic>) keys.addAll(_keys(value, path));
  }
  return keys;
}

Set<String> _localeKeys(String locale) {
  final file = File('lib/i18n/$locale.i18n.json');
  return _keys(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
}

/// Plural categories a language may add on its own: Slovenian has dual and
/// paucal forms English does not.
const _pluralForms = {'.zero', '.one', '.two', '.few', '.many', '.other'};

void main() {
  final base = _localeKeys('en');

  for (final locale in ['sl', 'de']) {
    test('$locale translates every key of the base locale', () {
      final missing = base.difference(_localeKeys(locale)).toList()..sort();
      expect(
        missing,
        isEmpty,
        reason: '$locale silently falls back to English for these keys',
      );
    });

    test('$locale carries no key the base locale lacks (typos, leftovers)', () {
      final extra = _localeKeys(locale)
          .difference(base)
          // A plural form the base language does not need is not a leftover.
          .where((k) => !_pluralForms.any(k.endsWith))
          .toList()
        ..sort();
      expect(extra, isEmpty, reason: '$locale has keys en does not');
    });
  }

  test('the base locale is not empty (the files were actually read)', () {
    expect(base.length, greaterThan(200));
  });
}
