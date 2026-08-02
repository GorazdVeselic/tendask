import '../../../i18n/translations.g.dart';

/// Upper-cases the first letter for standalone display of lowercase i18n
/// values ("fruit day" → "Fruit day"). Shared by the moon surfaces (sheet,
/// week agenda, task section).
String sentenceCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// i18n weekday_short key per weekday (DateTime.weekday is Mon=1..Sun=7).
const _weekdayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// Short weekday name ("Fri"). Map completeness is enforced by i18n tests.
String weekdayShort(Translations t, DateTime date) =>
    t.moon.calendar.weekday_short[_weekdayKeys[date.weekday - 1]]!;
