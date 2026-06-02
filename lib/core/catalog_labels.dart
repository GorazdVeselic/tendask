import 'dart:convert';

import '../i18n/translations.g.dart';

/// Picks the localized label from a catalog `labels` JSON (`{sl,en,de}`).
/// Falls back to English, then the raw string; never throws.
String catalogLabel(String labelsJson, [String? locale]) {
  final lang = locale ?? LocaleSettings.currentLocale.languageTag;
  try {
    final m = jsonDecode(labelsJson) as Map<String, dynamic>;
    return (m[lang] ?? m['en'] ?? labelsJson) as String;
  } catch (_) {
    return labelsJson;
  }
}
