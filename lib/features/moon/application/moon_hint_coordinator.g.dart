// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moon_hint_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the moon "tomorrow is a X day" hint armed (FR-19 T4b): a device-local
/// notification the evening before a day the user's garden can use. Re-arms at
/// startup, on resume, and whenever the moon settings, the garden or the
/// profile change — so the copy is re-derived (never frozen) and a zodiac
/// system switch is honoured immediately. Lives for the whole session; call
/// [start] after bootstrap.

@ProviderFor(MoonHintCoordinator)
final moonHintCoordinatorProvider = MoonHintCoordinatorProvider._();

/// Keeps the moon "tomorrow is a X day" hint armed (FR-19 T4b): a device-local
/// notification the evening before a day the user's garden can use. Re-arms at
/// startup, on resume, and whenever the moon settings, the garden or the
/// profile change — so the copy is re-derived (never frozen) and a zodiac
/// system switch is honoured immediately. Lives for the whole session; call
/// [start] after bootstrap.
final class MoonHintCoordinatorProvider
    extends $NotifierProvider<MoonHintCoordinator, void> {
  /// Keeps the moon "tomorrow is a X day" hint armed (FR-19 T4b): a device-local
  /// notification the evening before a day the user's garden can use. Re-arms at
  /// startup, on resume, and whenever the moon settings, the garden or the
  /// profile change — so the copy is re-derived (never frozen) and a zodiac
  /// system switch is honoured immediately. Lives for the whole session; call
  /// [start] after bootstrap.
  MoonHintCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moonHintCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moonHintCoordinatorHash();

  @$internal
  @override
  MoonHintCoordinator create() => MoonHintCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$moonHintCoordinatorHash() =>
    r'c244dc976d708e866216b85858593c51d9b9bf0a';

/// Keeps the moon "tomorrow is a X day" hint armed (FR-19 T4b): a device-local
/// notification the evening before a day the user's garden can use. Re-arms at
/// startup, on resume, and whenever the moon settings, the garden or the
/// profile change — so the copy is re-derived (never frozen) and a zodiac
/// system switch is honoured immediately. Lives for the whole session; call
/// [start] after bootstrap.

abstract class _$MoonHintCoordinator extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
