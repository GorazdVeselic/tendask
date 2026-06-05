// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_pull_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncPullService)
final syncPullServiceProvider = SyncPullServiceProvider._();

final class SyncPullServiceProvider
    extends
        $FunctionalProvider<
          SyncPullService?,
          SyncPullService?,
          SyncPullService?
        >
    with $Provider<SyncPullService?> {
  SyncPullServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPullServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPullServiceHash();

  @$internal
  @override
  $ProviderElement<SyncPullService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncPullService? create(Ref ref) {
    return syncPullService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPullService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPullService?>(value),
    );
  }
}

String _$syncPullServiceHash() => r'79d9b845aea2a5e8af4bc510838b24523d4cec35';
