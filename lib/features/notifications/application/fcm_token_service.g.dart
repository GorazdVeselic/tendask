// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_token_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps profile.fcm_token in sync with the device's FCM registration token
/// (docs/m11/06-fcm.md §6.2). The token is acquired only after sign-in (the
/// engine never pushes to guests) and once POST_NOTIFICATIONS is granted —
/// before that getToken() on A13+ returns a token nothing can display.
/// Re-runs on auth changes; screen 22 invalidates it after the permission flow.

@ProviderFor(FcmTokenService)
final fcmTokenServiceProvider = FcmTokenServiceProvider._();

/// Keeps profile.fcm_token in sync with the device's FCM registration token
/// (docs/m11/06-fcm.md §6.2). The token is acquired only after sign-in (the
/// engine never pushes to guests) and once POST_NOTIFICATIONS is granted —
/// before that getToken() on A13+ returns a token nothing can display.
/// Re-runs on auth changes; screen 22 invalidates it after the permission flow.
final class FcmTokenServiceProvider
    extends $AsyncNotifierProvider<FcmTokenService, void> {
  /// Keeps profile.fcm_token in sync with the device's FCM registration token
  /// (docs/m11/06-fcm.md §6.2). The token is acquired only after sign-in (the
  /// engine never pushes to guests) and once POST_NOTIFICATIONS is granted —
  /// before that getToken() on A13+ returns a token nothing can display.
  /// Re-runs on auth changes; screen 22 invalidates it after the permission flow.
  FcmTokenServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmTokenServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmTokenServiceHash();

  @$internal
  @override
  FcmTokenService create() => FcmTokenService();
}

String _$fcmTokenServiceHash() => r'506ea2c9c55b514532431fd0530401f23b8074e6';

/// Keeps profile.fcm_token in sync with the device's FCM registration token
/// (docs/m11/06-fcm.md §6.2). The token is acquired only after sign-in (the
/// engine never pushes to guests) and once POST_NOTIFICATIONS is granted —
/// before that getToken() on A13+ returns a token nothing can display.
/// Re-runs on auth changes; screen 22 invalidates it after the permission flow.

abstract class _$FcmTokenService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
