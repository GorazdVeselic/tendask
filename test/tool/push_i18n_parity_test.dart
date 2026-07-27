import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_push_i18n.dart';

/// The push titles the engine sends are generated from lib/i18n. Nothing forces
/// anyone to re-run the generator after editing a `suggestions.*.title`, and the
/// file has already gone stale once on this branch — a push would then carry an
/// old title, or the generic fallback, in the user's language.
void main() {
  test('committed push_i18n.ts matches lib/i18n (run tool/gen_push_i18n.dart)', () {
    final committed =
        File('supabase/functions/_shared/push_i18n.ts').readAsStringSync();
    // Normalize EOL: git may check the file out as CRLF; the generator emits LF.
    String norm(String s) => s.replaceAll('\r\n', '\n');
    expect(norm(buildPushI18n()), norm(committed));
  });
}
