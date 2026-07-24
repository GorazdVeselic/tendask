import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/local_prefs/local_prefs.dart';

part 'theme_mode_controller.g.dart';

ThemeMode _parse(String? raw) => ThemeMode.values.firstWhere(
  (m) => m.name == raw,
  orElse: () => ThemeMode.system,
);

/// The user's chosen [ThemeMode], persisted device-locally (never synced — it is
/// a per-device UI preference). Defaults to [ThemeMode.system] until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// theme without a flash.
@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  Future<ThemeMode> build() async => _parse(
    await ref.watch(localPrefsProvider).themeMode(),
  );

  Future<void> set(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(localPrefsProvider).setThemeMode(mode.name);
  }
}
