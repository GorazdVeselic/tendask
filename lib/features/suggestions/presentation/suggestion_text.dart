import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import '../../plants/presentation/plant_display.dart';

/// Builds the `{marker}` display values for a suggestion from its row plus the
/// already-resolved subject/task labels. `*_date` params are formatted for
/// display; everything else passes through as-is. `subject`/`task` come from the
/// row (the card resolves them) and are always available, unlike the optional
/// engine params. The client never computes message content — only formats.
Map<String, String> suggestionDisplayParams(
  Suggestion s, {
  required String subject,
  required String task,
}) {
  final out = <String, String>{'subject': subject, 'task': task};
  final Map<String, dynamic> params;
  try {
    params = jsonDecode(s.messageParams) as Map<String, dynamic>;
  } catch (_) {
    return out; // tolerant: malformed params → just subject/task
  }
  for (final e in params.entries) {
    final v = e.value;
    if (v == null) continue;
    if (e.key.endsWith('_date')) {
      // Format a parseable date; otherwise keep the raw value (never blank out).
      final d = DateTime.tryParse(v.toString());
      out[e.key] = d != null ? formatDmy(d) : v.toString();
    } else if (v is double && v == v.truncateToDouble()) {
      // A whole number decoded as double (e.g. percent 70.0) reads "70", not "70.0".
      out[e.key] = v.toInt().toString();
    } else {
      out[e.key] = v.toString();
    }
  }
  return out;
}

/// Fills `{placeholder}` markers in a localized suggestion template with display
/// values. A missing key collapses to empty — the engine omits optional params
/// (e.g. `frost_date` only for frost rules), and the template tolerates that.
///
/// Markers are deliberately `{...}`, not slang params: slang's dart
/// interpolation leaves `{...}` untouched, so the message catalog stays a plain
/// string and the client does pure substitution from `message_params`. The
/// client never computes message content (docs/m11/03 §Sporočila).
String fillTemplate(String template, Map<String, String> values) => template
    .replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) => values[m.group(1)] ?? '');

/// Looks up a localized template by its dynamic message_key (flat slang access)
/// and fills its markers; null when the key is missing (caller falls back).
/// Shared by the Home band card and the history screen.
String? suggestionMessage(
  Translations t,
  String key,
  Map<String, String> values,
) {
  final template = t[key];
  return template is String ? fillTemplate(template, values) : null;
}

/// Resolves the display label of a suggestion's subject (plant or area); empty
/// for `cat:` suggestions, which have no concrete subject. Never throws.
String suggestionSubjectLabel(
  Suggestion s,
  Map<String, UserPlant> userPlants,
  Map<String, Plant> plants,
  Map<String, Area> areas,
) {
  if (s.userPlantId != null) {
    final up = userPlants[s.userPlantId];
    return up != null ? userPlantLabel(up, plants) : '';
  }
  if (s.areaId != null) return areas[s.areaId]?.name ?? '';
  return '';
}
