import 'package:flutter/material.dart';

import '../../../i18n/translations.g.dart';

/// The palette names live in i18n; resolve by id (green for anything unknown —
/// a palette id dropped from a future build must not blank the label).
String paletteName(String id, Translations t) {
  final a = t.appearance;
  return switch (id) {
    'lavender' => a.palette_lavender,
    'ocean' => a.palette_ocean,
    'clay' => a.palette_clay,
    'berry' => a.palette_berry,
    'nebo' => a.palette_nebo,
    _ => a.palette_green,
  };
}

/// The light/dark actually in effect — the palette mini-previews must render in
/// the current brightness, which under "system" is the platform's, not the app's.
Brightness effectiveBrightness(ThemeMode mode, Brightness platform) =>
    switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platform,
    };
