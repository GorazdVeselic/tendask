import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/features/notifications/application/fcm_token_service.dart';

class _FakeAuth implements AuthService {
  _FakeAuth({this.hasSession = true});

  @override
  final bool hasSession;
  @override
  final String userId = 'user-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeMessaging implements FcmMessaging {
  _FakeMessaging({
    this.authorized = true,
    this.token = 'tok-1',
    this.getTokenError,
  });

  final bool authorized;
  final String? token;
  final Object? getTokenError;
  final refresh = StreamController<String>.broadcast();
  int getTokenCalls = 0;

  /// Subscribers currently listening. A broadcast controller's own hasListener
  /// cannot tell one listener from two, and two is the leak under test.
  int liveSubscriptions = 0;

  @override
  Future<bool> isAuthorized() async => authorized;

  @override
  Stream<String> get onTokenRefresh {
    final tracked = StreamController<String>();
    StreamSubscription<String>? upstream;
    tracked
      ..onListen = () {
        liveSubscriptions++;
        upstream = refresh.stream.listen(tracked.add);
      }
      ..onCancel = () async {
        liveSubscriptions--;
        await upstream?.cancel();
      };
    return tracked.stream;
  }

  @override
  Future<String?> getToken() async {
    getTokenCalls++;
    final error = getTokenError;
    if (error != null) throw error;
    return token;
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  ProviderContainer boot({
    required _FakeMessaging messaging,
    _FakeAuth? auth,
  }) {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith((ref) => db),
        authServiceProvider.overrideWith((ref) => auth ?? _FakeAuth()),
        fcmMessagingProvider.overrideWith((ref) => messaging),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// The profile row is born via the sign-in claim / first pull; updateFcmToken
  /// is update-only, so every write path needs it to exist first.
  Future<void> seedProfile(String userId) => db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(userId: userId, updatedAt: DateTime.utc(2026)),
      );

  Future<String?> storedToken(String userId) async {
    final row = await (db.select(
      db.profiles,
    )..where((p) => p.userId.equals(userId))).getSingleOrNull();
    return row?.fcmToken;
  }

  test('a guest never asks the plugin for a token', () async {
    final messaging = _FakeMessaging();
    final container = boot(
      messaging: messaging,
      auth: _FakeAuth(hasSession: false),
    );

    await container.read(fcmTokenServiceProvider.future);

    expect(messaging.getTokenCalls, 0);
  });

  test('a denied permission stores nothing and does not listen', () async {
    // getToken() on A13+ answers even without POST_NOTIFICATIONS — a token
    // nothing can display, so the profile must stay empty.
    final messaging = _FakeMessaging(authorized: false);
    await seedProfile('user-1');
    final container = boot(messaging: messaging);

    await container.read(fcmTokenServiceProvider.future);

    expect(messaging.getTokenCalls, 0);
    expect(await storedToken('user-1'), isNull);
    expect(messaging.liveSubscriptions, 0);
  });

  test('an authorized device mirrors the token into the profile', () async {
    await seedProfile('user-1');
    final container = boot(messaging: _FakeMessaging());

    await container.read(fcmTokenServiceProvider.future);

    expect(await storedToken('user-1'), 'tok-1');
  });

  test('a null token stores nothing', () async {
    await seedProfile('user-1');
    final container = boot(messaging: _FakeMessaging(token: null));

    await container.read(fcmTokenServiceProvider.future);

    expect(await storedToken('user-1'), isNull);
  });

  test('a rotated token replaces the stored one', () async {
    final messaging = _FakeMessaging();
    await seedProfile('user-1');
    final container = boot(messaging: messaging);
    await container.read(fcmTokenServiceProvider.future);

    messaging.refresh.add('tok-2');
    await Future<void>.delayed(Duration.zero);

    expect(await storedToken('user-1'), 'tok-2');
  });

  test('a rotation arriving before the profile row still lands', () async {
    // The listener is subscribed before getToken so an offline boot, where the
    // profile appears only after the pull, does not lose the registration.
    final messaging = _FakeMessaging(token: null);
    final container = boot(messaging: messaging);
    await container.read(fcmTokenServiceProvider.future);

    messaging.refresh.add('tok-2');
    await Future<void>.delayed(Duration.zero);
    await seedProfile('user-1');
    await Future<void>.delayed(Duration.zero);

    expect(await storedToken('user-1'), 'tok-2');
  });

  test('a plugin failure is swallowed — sync pull still delivers', () async {
    await seedProfile('user-1');
    final container = boot(
      messaging: _FakeMessaging(getTokenError: StateError('no Firebase')),
    );

    await expectLater(container.read(fcmTokenServiceProvider.future), completes);
    expect(await storedToken('user-1'), isNull);
  });

  test('a rebuild keeps exactly one live refresh subscription', () async {
    final messaging = _FakeMessaging();
    await seedProfile('user-1');
    final container = boot(messaging: messaging);
    await container.read(fcmTokenServiceProvider.future);

    container.invalidate(fcmTokenServiceProvider);
    await container.read(fcmTokenServiceProvider.future);

    // A leaked listener would keep writing under the previous user's id after
    // a sign-out rebuild.
    expect(messaging.liveSubscriptions, 1);
    messaging.refresh.add('tok-2');
    await Future<void>.delayed(Duration.zero);
    expect(await storedToken('user-1'), 'tok-2');
  });

  test('disposing the service cancels the refresh subscription', () async {
    final messaging = _FakeMessaging();
    await seedProfile('user-1');
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith((ref) => db),
        authServiceProvider.overrideWith((ref) => _FakeAuth()),
        fcmMessagingProvider.overrideWith((ref) => messaging),
      ],
    );
    await container.read(fcmTokenServiceProvider.future);

    container.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(messaging.liveSubscriptions, 0);
  });
}
