import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_engine_fixture.dart';

/// Same invariant as catalog_sql_parity_test / rules_sql_parity_test: the
/// committed fixture the Deno season simulation imports still reflects the
/// bundled seeds. If this fails, regenerate
/// (`dart run tool/gen_engine_fixture.dart`) — a stale fixture means the
/// simulation measures rules that are no longer shipped.
void main() {
  test('committed catalog_fixture.ts matches the seeds', () {
    final committed = File(
      'supabase/functions/smart-engine/testdata/catalog_fixture.ts',
    ).readAsStringSync();
    // Normalize EOL: git may check the file out as CRLF; the generator emits LF.
    String norm(String s) => s.replaceAll('\r\n', '\n');
    expect(norm(buildEngineFixture()), norm(committed));
  });
}
