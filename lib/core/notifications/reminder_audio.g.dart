// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_audio.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reminderAudioService)
final reminderAudioServiceProvider = ReminderAudioServiceProvider._();

final class ReminderAudioServiceProvider
    extends
        $FunctionalProvider<
          ReminderAudioService,
          ReminderAudioService,
          ReminderAudioService
        >
    with $Provider<ReminderAudioService> {
  ReminderAudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderAudioServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderAudioServiceHash();

  @$internal
  @override
  $ProviderElement<ReminderAudioService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReminderAudioService create(Ref ref) {
    return reminderAudioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderAudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderAudioService>(value),
    );
  }
}

String _$reminderAudioServiceHash() =>
    r'375d900040979a89181de04182b01e09b3cda08a';
