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
    r'0faeb7bf3b54dfef7e6e50b2a770999280cf3c17';

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

/// The zodiac system every moon surface reads (one system drives them all,
/// spec §11.6). Sidereal while the settings are still loading or if they
/// failed — the same fallback everywhere, so no two surfaces can disagree.

@ProviderFor(moonSystem)
final moonSystemProvider = MoonSystemProvider._();

/// The zodiac system every moon surface reads (one system drives them all,
/// spec §11.6). Sidereal while the settings are still loading or if they
/// failed — the same fallback everywhere, so no two surfaces can disagree.

final class MoonSystemProvider
    extends $FunctionalProvider<CalendarSystem, CalendarSystem, CalendarSystem>
    with $Provider<CalendarSystem> {
  /// The zodiac system every moon surface reads (one system drives them all,
  /// spec §11.6). Sidereal while the settings are still loading or if they
  /// failed — the same fallback everywhere, so no two surfaces can disagree.
  MoonSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moonSystemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moonSystemHash();

  @$internal
  @override
  $ProviderElement<CalendarSystem> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CalendarSystem create(Ref ref) {
    return moonSystem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarSystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarSystem>(value),
    );
  }
}

String _$moonSystemHash() => r'c66e77bde3d381f70448a7540d20313e75c52b4f';
