// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weatherService)
final weatherServiceProvider = WeatherServiceProvider._();

final class WeatherServiceProvider
    extends $FunctionalProvider<WeatherService, WeatherService, WeatherService>
    with $Provider<WeatherService> {
  WeatherServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherServiceHash();

  @$internal
  @override
  $ProviderElement<WeatherService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeatherService create(Ref ref) {
    return weatherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherService>(value),
    );
  }
}

String _$weatherServiceHash() => r'b5bb3beda866575759dc239d55821f9ceb7ece55';

/// Live weather for the dashboard (current conditions + short forecast) at the
/// garden location, cached for [kWeatherCacheTtl]. Null when offline with no
/// prior snapshot — the UI degrades to a quiet hint.

@ProviderFor(currentWeather)
final currentWeatherProvider = CurrentWeatherProvider._();

/// Live weather for the dashboard (current conditions + short forecast) at the
/// garden location, cached for [kWeatherCacheTtl]. Null when offline with no
/// prior snapshot — the UI degrades to a quiet hint.

final class CurrentWeatherProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeatherSnapshot?>,
          WeatherSnapshot?,
          FutureOr<WeatherSnapshot?>
        >
    with $FutureModifier<WeatherSnapshot?>, $FutureProvider<WeatherSnapshot?> {
  /// Live weather for the dashboard (current conditions + short forecast) at the
  /// garden location, cached for [kWeatherCacheTtl]. Null when offline with no
  /// prior snapshot — the UI degrades to a quiet hint.
  CurrentWeatherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentWeatherProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentWeatherHash();

  @$internal
  @override
  $FutureProviderElement<WeatherSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeatherSnapshot?> create(Ref ref) {
    return currentWeather(ref);
  }
}

String _$currentWeatherHash() => r'4a5e7d3d2e4a0038aa04874332d87c6b83cedbcc';
