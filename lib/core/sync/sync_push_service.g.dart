// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncPushService)
final syncPushServiceProvider = SyncPushServiceProvider._();

final class SyncPushServiceProvider
    extends
        $FunctionalProvider<
          SyncPushService?,
          SyncPushService?,
          SyncPushService?
        >
    with $Provider<SyncPushService?> {
  SyncPushServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPushServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPushServiceHash();

  @$internal
  @override
  $ProviderElement<SyncPushService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncPushService? create(Ref ref) {
    return syncPushService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPushService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPushService?>(value),
    );
  }
}

String _$syncPushServiceHash() => r'9dd33927afa024a07278ff5fbcca17f79798f273';
