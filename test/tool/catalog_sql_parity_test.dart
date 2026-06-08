import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_catalog_sql.dart';

/// Guards invariant #4: the committed cloud seed (supabase/seed/catalog.sql)
/// still reflects the on-device seed. If this fails, regenerate the SQL
/// (`dart run tool/gen_catalog_sql.dart`) and re-apply it — otherwise a pushed
/// row could reference a catalog id the cloud does not have (FK violation).
void main() {
  test(
    'committed catalog.sql matches the seed (cloud ⊇ every referenced id)',
    () {
      final committed = File('supabase/seed/catalog.sql').readAsStringSync();
      // Normalize EOL: git may check the file out as CRLF; the generator emits LF.
      String norm(String s) => s.replaceAll('\r\n', '\n');
      expect(norm(buildCatalogSql()), norm(committed));
    },
  );
}
