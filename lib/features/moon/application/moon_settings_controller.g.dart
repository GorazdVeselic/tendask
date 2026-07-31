// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moon_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Defaults: enabled (decision A6),
/// sidereal (matches the printed calendars the target market compares against).
/// Warmed in bootstrap before the first paint so the Home chip never flashes.
/// The single [MoonSettings.system] here drives ALL moon screens (spec §11.6).

@ProviderFor(MoonSettingsController)
final moonSettingsControllerProvider = MoonSettingsControllerProvider._();

/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Defaults: enabled (decision A6),
/// sidereal (matches the printed calendars the target market compares against).
/// Warmed in bootstrap before the first paint so the Home chip never flashes.
/// The single [MoonSettings.system] here drives ALL moon screens (spec §11.6).
final class MoonSettingsControllerProvider
    extends $AsyncNotifierProvider<MoonSettingsController, MoonSettings> {
  /// The user's moon calendar settings, persisted device-locally (never synced —
  /// the calendar is global, not user data). Defaults: enabled (decision A6),
  /// sidereal (matches the printed calendars the target market compares against).
  /// Warmed in bootstrap before the first paint so the Home chip never flashes.
  /// The single [MoonSettings.system] here drives ALL moon screens (spec §11.6).
  MoonSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moonSettingsControllerProvider',
        isAutoDispose: true,
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
    r'ee56cf8296a06c0e9b17452bbc85733960c5d18e';

/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Defaults: enabled (decision A6),
/// sidereal (matches the printed calendars the target market compares against).
/// Warmed in bootstrap before the first paint so the Home chip never flashes.
/// The single [MoonSettings.system] here drives ALL moon screens (spec §11.6).

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
