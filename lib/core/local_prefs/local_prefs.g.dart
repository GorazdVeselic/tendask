// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localPrefs)
final localPrefsProvider = LocalPrefsProvider._();

final class LocalPrefsProvider
    extends
        $FunctionalProvider<
          LocalPrefsRepository,
          LocalPrefsRepository,
          LocalPrefsRepository
        >
    with $Provider<LocalPrefsRepository> {
  LocalPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localPrefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localPrefsHash();

  @$internal
  @override
  $ProviderElement<LocalPrefsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalPrefsRepository create(Ref ref) {
    return localPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalPrefsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalPrefsRepository>(value),
    );
  }
}

String _$localPrefsHash() => r'893a1ba0c631524589c4d1c18a0f07d66e05d667';
