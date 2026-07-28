import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A fixture that names an i18n key which does not exist never fails — the
/// renderer falls back and the test keeps passing, only it has stopped
/// measuring anything (najdba N26: the layout matrix fed the suggestion band
/// `suggestions.season.window_open`, a key with no `season` subtree at all, and
/// stayed green for as long as it existed).
///
/// So: every dotted key a test hands to the app must resolve in all three
/// catalogs. The exceptions below are keys that never reach a widget.
void main() {
  Map<String, dynamic> load(String locale) =>
      jsonDecode(File('lib/i18n/$locale.i18n.json').readAsStringSync())
          as Map<String, dynamic>;

  final catalogs = {
    for (final l in ['en', 'sl', 'de']) l: load(l),
  };
  final roots = catalogs['en']!.keys.toSet();

  /// message_key values in persistence tests: drift roundtrip, GDPR export,
  /// sync mapping and a migration. Nothing there renders the string — it is
  /// opaque payload on its way to a column and back, and inventing a real key
  /// would suggest the test cares which one it is.
  const opaque = {
    'suggestions.water', // export_user_data_test, migration_v9_test
    'suggestions.prune',
    'suggestions.prune_window', // sync_roundtrip_test
    'suggestions.x', // remote_mappers_test
  };

  dynamic resolve(Map<String, dynamic> root, String key) {
    dynamic node = root;
    for (final part in key.split('.')) {
      if (node is! Map<String, dynamic> || !node.containsKey(part)) return null;
      node = node[part];
    }
    return node;
  }

  test('every i18n key a test names exists in all three catalogs', () {
    // Single-quoted dotted literals whose first segment is a catalog root.
    // Comments are stripped first: the fix for N26 quotes the dead key in a
    // comment, and a guard that trips over its own scar is worse than none.
    final literal = RegExp(r"'([a-z][a-z0-9_]*(?:\.[a-z0-9_]+)+)'");
    final comment = RegExp(r'//.*$', multiLine: true);

    final seen = <String, String>{};
    for (final file
        in Directory('test')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync().replaceAll(comment, '');
      for (final m in literal.allMatches(source)) {
        final key = m.group(1)!;
        if (roots.contains(key.split('.').first) && !opaque.contains(key)) {
          seen.putIfAbsent(key, () => file.path);
        }
      }
    }

    expect(seen, isNotEmpty, reason: 'the scan found no keys at all');
    catalogs.forEach((locale, root) {
      seen.forEach((key, where) {
        expect(
          resolve(root, key),
          isNotNull,
          reason: '$where names $key, which $locale does not have',
        );
      });
    });
  });

  test('a message_key subtree carries a title, not just a name', () {
    // Resolving to a Map means the key is a message_key (title + body). One
    // without a title renders the task-type name and an empty body — the same
    // silent fallback, one level down.
    final root = catalogs['en']!;
    for (final key in ['suggestions.vegetable.plant_out']) {
      final node = resolve(root, key);
      expect(node, isA<Map<String, dynamic>>(), reason: key);
      expect((node as Map<String, dynamic>)['title'], isA<String>());
    }
  });
}
