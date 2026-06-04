// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits the device's online/offline status, de-duplicated so an unchanged
/// state never triggers a needless rebuild/flush. keepAlive: the sync service
/// listens for the whole app lifetime.

@ProviderFor(onlineStatus)
final onlineStatusProvider = OnlineStatusProvider._();

/// Emits the device's online/offline status, de-duplicated so an unchanged
/// state never triggers a needless rebuild/flush. keepAlive: the sync service
/// listens for the whole app lifetime.

final class OnlineStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Emits the device's online/offline status, de-duplicated so an unchanged
  /// state never triggers a needless rebuild/flush. keepAlive: the sync service
  /// listens for the whole app lifetime.
  OnlineStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineStatusHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return onlineStatus(ref);
  }
}

String _$onlineStatusHash() => r'24e52c3ee04106ccf4ebbd41b8e186424d79ca42';
