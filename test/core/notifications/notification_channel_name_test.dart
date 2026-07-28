import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Channel names are the one piece of app text Android renders outside the app,
/// in system notification settings. They used to be Slovenian constants, so a
/// German user read "Opomniki opravil" in a screen the app never draws — and no
/// i18n test could see it, because the string was not in the catalog at all.
///
/// The wiring is checked against the source rather than against a posted
/// notification: `init()` needs a platform implementation, so off-device the
/// plugin never gets far enough to report the name it would have used.
void main() {
  test('every channel takes its name from the catalog', () {
    final dir = Directory('lib/core/notifications');
    final sources = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

    // The channel name is the second positional argument of both constructors.
    final ctor = RegExp(
      r'AndroidNotification(?:Channel|Details)\(\s*([^,]+),\s*([^,]+),',
      multiLine: true,
    );

    var checked = 0;
    for (final file in sources) {
      for (final m in ctor.allMatches(file.readAsStringSync())) {
        checked++;
        expect(
          m.group(2)!.trim(),
          startsWith('t.notif_channel.'),
          reason:
              '${file.path}: channel ${m.group(1)!.trim()} is named with a '
              'literal instead of a translation',
        );
      }
    }
    // Nothing found means the regex stopped matching, not that the code is
    // clean — the guard has to prove it is still looking at something (N26).
    expect(checked, greaterThanOrEqualTo(4));
  });

  test('the three languages do not share one channel name', () {
    final byLocale = {
      for (final l in AppLocale.values)
        l: LocaleSettings.instance.translationMap[l]!.notif_channel,
    };
    // A missing translation falls back to the base locale, which would leave a
    // German user with an English name and no test would notice.
    final names = {
      'reminders': (Translations$notif_channel$en c) => c.reminders,
      'suggestions': (Translations$notif_channel$en c) => c.suggestions,
      'journal_nudge': (Translations$notif_channel$en c) => c.journal_nudge,
    };
    names.forEach((key, read) {
      final values = {for (final e in byLocale.entries) e.key: read(e.value)};
      expect(
        values.values.toSet(),
        hasLength(AppLocale.values.length),
        reason: '$key is not translated in every language: $values',
      );
    });
  });
}
