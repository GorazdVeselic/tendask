import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/local_prefs/local_prefs.dart';
import 'theme_palette.dart';

part 'theme_palette_controller.g.dart';

/// The user's chosen colour [ThemePalette], persisted device-locally (never
/// synced — a per-device UI preference). Defaults to green until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// palette without a flash.
@riverpod
class ThemePaletteController extends _$ThemePaletteController {
  @override
  Future<ThemePalette> build() async =>
      paletteForId(await ref.watch(localPrefsProvider).themePalette());

  Future<void> set(String id) async {
    final palette = paletteForId(id);
    state = AsyncData(palette);
    await ref.read(localPrefsProvider).setThemePalette(palette.id);
  }
}
