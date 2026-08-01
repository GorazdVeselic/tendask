// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moon_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Warmed in bootstrap before the
/// first paint so the Home chip never flashes; kept alive because nothing
/// listens until the first moon UI subscribes (autoDispose would drop the
/// warmed value right after bootstrap). The single [MoonSettings.system] here
/// drives ALL moon screens (spec §11.6).

@ProviderFor(MoonSettingsController)
final moonSettingsControllerProvider = MoonSettingsControllerProvider._();

/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Warmed in bootstrap before the
/// first paint so the Home chip never flashes; kept alive because nothing
/// listens until the first moon UI subscribes (autoDispose would drop the
/// warmed value right after bootstrap). The single [MoonSettings.system] here
/// drives ALL moon screens (spec §11.6).
final class MoonSettingsControllerProvider
    extends $AsyncNotifierProvider<MoonSettingsController, MoonSettings> {
  /// The user's moon calendar settings, persisted device-locally (never synced —
  /// the calendar is global, not user data). Warmed in bootstrap before the
  /// first paint so the Home chip never flashes; kept alive because nothing
  /// listens until the first moon UI subscribes (autoDispose would drop the
  /// warmed value right after bootstrap). The single [MoonSettings.system] here
  /// drives ALL moon screens (spec §11.6).
  MoonSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moonSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moonSettingsControllerHash();

  @$internal
  @override
  MoonSettingsController create() => MoonSettingsController();
}

String _$moonSettingsControllerHash() =>
    r'344f190b74b3fc58300a3295d1a0b7f46baa2bbc';

/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Warmed in bootstrap before the
/// first paint so the Home chip never flashes; kept alive because nothing
/// listens until the first moon UI subscribes (autoDispose would drop the
/// warmed value right after bootstrap). The single [MoonSettings.system] here
/// drives ALL moon screens (spec §11.6).

abstract class _$MoonSettingsController extends $AsyncNotifier<MoonSettings> {
  FutureOr<MoonSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MoonSettings>, MoonSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MoonSettings>, MoonSettings>,
              AsyncValue<MoonSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
