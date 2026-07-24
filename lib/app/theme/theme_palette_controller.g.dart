// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_palette_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's chosen colour [ThemePalette], persisted device-locally (never
/// synced — a per-device UI preference). Defaults to green until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// palette without a flash.

@ProviderFor(ThemePaletteController)
final themePaletteControllerProvider = ThemePaletteControllerProvider._();

/// The user's chosen colour [ThemePalette], persisted device-locally (never
/// synced — a per-device UI preference). Defaults to green until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// palette without a flash.
final class ThemePaletteControllerProvider
    extends $AsyncNotifierProvider<ThemePaletteController, ThemePalette> {
  /// The user's chosen colour [ThemePalette], persisted device-locally (never
  /// synced — a per-device UI preference). Defaults to green until changed.
  /// Warmed in bootstrap before the first paint so the app opens in the chosen
  /// palette without a flash.
  ThemePaletteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themePaletteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themePaletteControllerHash();

  @$internal
  @override
  ThemePaletteController create() => ThemePaletteController();
}

String _$themePaletteControllerHash() =>
    r'1ee23e8e3f55ac939ba40d9bc115a78c61b748e0';

/// The user's chosen colour [ThemePalette], persisted device-locally (never
/// synced — a per-device UI preference). Defaults to green until changed.
/// Warmed in bootstrap before the first paint so the app opens in the chosen
/// palette without a flash.

abstract class _$ThemePaletteController extends $AsyncNotifier<ThemePalette> {
  FutureOr<ThemePalette> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemePalette>, ThemePalette>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemePalette>, ThemePalette>,
              AsyncValue<ThemePalette>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
