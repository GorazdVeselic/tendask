// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the sync triggers (tech-stack §2): startup, reconnect, periodic, plus
/// push-on-save. keepAlive — lives for the whole app session. Instantiate once
/// after the bootstrap via `ref.read(syncCoordinatorProvider.notifier).start()`.

@ProviderFor(SyncCoordinator)
final syncCoordinatorProvider = SyncCoordinatorProvider._();

/// Wires the sync triggers (tech-stack §2): startup, reconnect, periodic, plus
/// push-on-save. keepAlive — lives for the whole app session. Instantiate once
/// after the bootstrap via `ref.read(syncCoordinatorProvider.notifier).start()`.
final class SyncCoordinatorProvider
    extends $NotifierProvider<SyncCoordinator, void> {
  /// Wires the sync triggers (tech-stack §2): startup, reconnect, periodic, plus
  /// push-on-save. keepAlive — lives for the whole app session. Instantiate once
  /// after the bootstrap via `ref.read(syncCoordinatorProvider.notifier).start()`.
  SyncCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncCoordinatorHash();

  @$internal
  @override
  SyncCoordinator create() => SyncCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$syncCoordinatorHash() => r'e4120e3a134d814358cca9440d1973f71641d23f';

/// Wires the sync triggers (tech-stack §2): startup, reconnect, periodic, plus
/// push-on-save. keepAlive — lives for the whole app session. Instantiate once
/// after the bootstrap via `ref.read(syncCoordinatorProvider.notifier).start()`.

abstract class _$SyncCoordinator extends $Notifier<void> {
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
