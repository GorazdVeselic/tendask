// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fcmHandler)
final fcmHandlerProvider = FcmHandlerProvider._();

final class FcmHandlerProvider
    extends $FunctionalProvider<FcmHandler, FcmHandler, FcmHandler>
    with $Provider<FcmHandler> {
  FcmHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmHandlerHash();

  @$internal
  @override
  $ProviderElement<FcmHandler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FcmHandler create(Ref ref) {
    return fcmHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FcmHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FcmHandler>(value),
    );
  }
}

String _$fcmHandlerHash() => r'c69513efb261c5ded20bd4706a696311454b4c0c';
