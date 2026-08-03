// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(plusRepository)
final plusRepositoryProvider = PlusRepositoryProvider._();

final class PlusRepositoryProvider
    extends $FunctionalProvider<PlusRepository, PlusRepository, PlusRepository>
    with $Provider<PlusRepository> {
  PlusRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlusRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlusRepository create(Ref ref) {
    return plusRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusRepository>(value),
    );
  }
}

String _$plusRepositoryHash() => r'b90365136cfb891a1c0ad0b4228340e588b7e11b';

/// Clock behind [plusProvider]; tests override it to travel past expiry.

@ProviderFor(plusClock)
final plusClockProvider = PlusClockProvider._();

/// Clock behind [plusProvider]; tests override it to travel past expiry.

final class PlusClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// Clock behind [plusProvider]; tests override it to travel past expiry.
  PlusClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusClockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return plusClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$plusClockHash() => r'15f8d11d9c2fddee21505322f8062a1c897939ff';

/// The bundled verification key, as one overridable seam: tests sign with their
/// own key pair, so [kPlusPublicKey] stays the single untested constant.

@ProviderFor(plusPublicKey)
final plusPublicKeyProvider = PlusPublicKeyProvider._();

/// The bundled verification key, as one overridable seam: tests sign with their
/// own key pair, so [kPlusPublicKey] stays the single untested constant.

final class PlusPublicKeyProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The bundled verification key, as one overridable seam: tests sign with their
  /// own key pair, so [kPlusPublicKey] stays the single untested constant.
  PlusPublicKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusPublicKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusPublicKeyHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return plusPublicKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$plusPublicKeyHash() => r'dcf81a5c4933b2c4ddec98dd0b36044a495ec8eb';
