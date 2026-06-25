// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's chosen [ThemeMode], persisted device-locally (never synced — it is
/// a per-device UI preference). Defaults to [ThemeMode.system] until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// theme without a flash.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// The user's chosen [ThemeMode], persisted device-locally (never synced — it is
/// a per-device UI preference). Defaults to [ThemeMode.system] until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// theme without a flash.
final class ThemeModeControllerProvider
    extends $AsyncNotifierProvider<ThemeModeController, ThemeMode> {
  /// The user's chosen [ThemeMode], persisted device-locally (never synced — it is
  /// a per-device UI preference). Defaults to [ThemeMode.system] until changed.
  /// Warmed in bootstrap before the first paint so the app opens in the chosen
  /// theme without a flash.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();
}

String _$themeModeControllerHash() =>
    r'507530ddd85224f92ca5048855132ae3fa4ac545';

/// The user's chosen [ThemeMode], persisted device-locally (never synced — it is
/// a per-device UI preference). Defaults to [ThemeMode.system] until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// theme without a flash.

abstract class _$ThemeModeController extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
