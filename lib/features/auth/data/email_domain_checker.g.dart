// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_domain_checker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
/// client's longer budget): the check is a sign-in pre-flight and must stay snappy.
/// keepAlive: the screen reads the checker one-shot (no listener), so an
/// autoDispose Dio would be closed by ref.onDispose the instant the read returns —
/// before the async lookup runs — killing every check. One long-lived client.

@ProviderFor(dnsDio)
final dnsDioProvider = DnsDioProvider._();

/// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
/// client's longer budget): the check is a sign-in pre-flight and must stay snappy.
/// keepAlive: the screen reads the checker one-shot (no listener), so an
/// autoDispose Dio would be closed by ref.onDispose the instant the read returns —
/// before the async lookup runs — killing every check. One long-lived client.

final class DnsDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
  /// client's longer budget): the check is a sign-in pre-flight and must stay snappy.
  /// keepAlive: the screen reads the checker one-shot (no listener), so an
  /// autoDispose Dio would be closed by ref.onDispose the instant the read returns —
  /// before the async lookup runs — killing every check. One long-lived client.
  DnsDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dnsDioProvider',
        isAutoDispose: false,
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

String _$dnsDioHash() => r'8d657d352f3f9118288e8e52f1f1a8660555bc36';

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
        isAutoDispose: false,
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
    r'0b401701e9c10153ab3f410946ab3b2de2a2c1d1';
