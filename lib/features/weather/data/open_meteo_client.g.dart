// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_meteo_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weatherDio)
final weatherDioProvider = WeatherDioProvider._();

final class WeatherDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  WeatherDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return weatherDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$weatherDioHash() => r'80b076171d63fe52344f56f4bae089da74d6a9b3';

@ProviderFor(openMeteoClient)
final openMeteoClientProvider = OpenMeteoClientProvider._();

final class OpenMeteoClientProvider
    extends
        $FunctionalProvider<OpenMeteoClient, OpenMeteoClient, OpenMeteoClient>
    with $Provider<OpenMeteoClient> {
  OpenMeteoClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openMeteoClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openMeteoClientHash();

  @$internal
  @override
  $ProviderElement<OpenMeteoClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpenMeteoClient create(Ref ref) {
    return openMeteoClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenMeteoClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenMeteoClient>(value),
    );
  }
}

String _$openMeteoClientHash() => r'166e8e8742b19a3bcbe6fac7176480f9196d26c1';
