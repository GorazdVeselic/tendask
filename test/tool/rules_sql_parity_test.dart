import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_rules_sql.dart';

/// Same invariant as catalog_sql_parity_test: the committed cloud seed
/// (supabase/seed/plant_task_rules.sql) still reflects the bundled seed. If
/// this fails, regenerate (`dart run tool/gen_rules_sql.dart`) and re-apply.
void main() {
  test('committed plant_task_rules.sql matches the seed', () {
    final committed = File(
      'supabase/seed/plant_task_rules.sql',
    ).readAsStringSync();
    // Normalize EOL: git may check the file out as CRLF; the generator emits LF.
    String norm(String s) => s.replaceAll('\r\n', '\n');
    expect(norm(buildRulesSql()), norm(committed));
  });
}
