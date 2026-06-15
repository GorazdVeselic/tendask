/// Fills `{placeholder}` markers in a localized suggestion template with display
/// values. A missing key collapses to empty — the engine omits optional params
/// (e.g. `frost_date` only for frost rules), and the template tolerates that.
///
/// Markers are deliberately `{...}`, not slang params: slang's dart
/// interpolation leaves `{...}` untouched, so the message catalog stays a plain
/// string and the client does pure substitution from `message_params`. The
/// client never computes message content (docs/m11/03 §Sporočila).
String fillTemplate(String template, Map<String, String> values) =>
    template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (m) => values[m.group(1)] ?? '',
    );
