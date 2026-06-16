// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_domain_checker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
/// client's longer budget): the check is a sign-in pre-flight and must stay snappy.

@ProviderFor(dnsDio)
final dnsDioProvider = DnsDioProvider._();

/// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
/// client's longer budget): the check is a sign-in pre-flight and must stay snappy.

final class DnsDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
  /// client's longer budget): the check is a sign-in pre-flight and must stay snappy.
  DnsDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dnsDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dnsDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dnsDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dnsDioHash() => r'1686159161b711dc2e615df2cf292acf891bd5f7';

@ProviderFor(emailDomainChecker)
final emailDomainCheckerProvider = EmailDomainCheckerProvider._();

final class EmailDomainCheckerProvider
    extends
        $FunctionalProvider<
          EmailDomainChecker,
          EmailDomainChecker,
          EmailDomainChecker
        >
    with $Provider<EmailDomainChecker> {
  EmailDomainCheckerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailDomainCheckerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailDomainCheckerHash();

  @$internal
  @override
  $ProviderElement<EmailDomainChecker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmailDomainChecker create(Ref ref) {
    return emailDomainChecker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmailDomainChecker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmailDomainChecker>(value),
    );
  }
}

String _$emailDomainCheckerHash() =>
    r'486418ef12a38c4d54b52f90bb4fdb99778e1539';
