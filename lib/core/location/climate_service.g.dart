// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'climate_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Own Dio: core must not import the weather feature's client providers.

@ProviderFor(_archiveDio)
final _archiveDioProvider = _ArchiveDioProvider._();

/// Own Dio: core must not import the weather feature's client providers.

final class _ArchiveDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Own Dio: core must not import the weather feature's client providers.
  _ArchiveDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_archiveDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_archiveDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return _archiveDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$_archiveDioHash() => r'd35fbef42942f494726695c4dc9f9a95e4404d21';

@ProviderFor(climateService)
final climateServiceProvider = ClimateServiceProvider._();

final class ClimateServiceProvider
    extends $FunctionalProvider<ClimateService, ClimateService, ClimateService>
    with $Provider<ClimateService> {
  ClimateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'climateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$climateServiceHash();

  @$internal
  @override
  $ProviderElement<ClimateService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClimateService create(Ref ref) {
    return climateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClimateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClimateService>(value),
    );
  }
}

String _$climateServiceHash() => r'42ea2355e1952c8ecc2bd8137905e71a962c9f80';
