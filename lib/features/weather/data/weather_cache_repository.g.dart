// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_cache_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weatherCacheRepository)
final weatherCacheRepositoryProvider = WeatherCacheRepositoryProvider._();

final class WeatherCacheRepositoryProvider
    extends
        $FunctionalProvider<
          WeatherCacheRepository,
          WeatherCacheRepository,
          WeatherCacheRepository
        >
    with $Provider<WeatherCacheRepository> {
  WeatherCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherCacheRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<WeatherCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeatherCacheRepository create(Ref ref) {
    return weatherCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherCacheRepository>(value),
    );
  }
}

String _$weatherCacheRepositoryHash() =>
    r'db8e50a5ed83623ddf6e707ef3d7e1d8434ea84b';
