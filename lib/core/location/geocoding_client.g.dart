// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geocodingClient)
final geocodingClientProvider = GeocodingClientProvider._();

final class GeocodingClientProvider
    extends
        $FunctionalProvider<GeocodingClient, GeocodingClient, GeocodingClient>
    with $Provider<GeocodingClient> {
  GeocodingClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geocodingClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geocodingClientHash();

  @$internal
  @override
  $ProviderElement<GeocodingClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeocodingClient create(Ref ref) {
    return geocodingClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeocodingClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeocodingClient>(value),
    );
  }
}

String _$geocodingClientHash() => r'4d1b4306ad447c08bda92980a27f9d73077a3f8b';
