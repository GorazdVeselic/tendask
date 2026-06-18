// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_geocoding_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reverseGeocodingClient)
final reverseGeocodingClientProvider = ReverseGeocodingClientProvider._();

final class ReverseGeocodingClientProvider
    extends
        $FunctionalProvider<
          ReverseGeocodingClient,
          ReverseGeocodingClient,
          ReverseGeocodingClient
        >
    with $Provider<ReverseGeocodingClient> {
  ReverseGeocodingClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reverseGeocodingClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reverseGeocodingClientHash();

  @$internal
  @override
  $ProviderElement<ReverseGeocodingClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReverseGeocodingClient create(Ref ref) {
    return reverseGeocodingClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReverseGeocodingClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReverseGeocodingClient>(value),
    );
  }
}

String _$reverseGeocodingClientHash() =>
    r'83354dbba09f7f08791d3b3f06fd2168f39710fa';
