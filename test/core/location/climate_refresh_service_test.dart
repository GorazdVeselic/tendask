import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/location/climate_refresh_service.dart';
import 'package:tendask/core/location/location_repository.dart';

/// Auth with a settable id — a real session needs Supabase, which a unit test
/// must not touch.
class _FakeAuth extends AuthService {
  _FakeAuth(this._userId) : super(null);
  String _userId;
  @override
  String get userId => _userId;
}

class _FakeH3 implements H3 {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// Records who the refresh was asked for; the fetch itself is covered by
/// location_repository_test / climate_service_test.
class _SpyLocationRepo extends LocationRepository {
  _SpyLocationRepo(AppDatabase db) : super(db, _FakeH3());
  final refreshedFor = <String>[];
  @override
  Future<void> refreshClimateIfStale(String userId) async =>
      refreshedFor.add(userId);
}

void main() {
  late AppDatabase db;
  late _SpyLocationRepo repo;
  late StreamController<AuthState> authEvents;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = _SpyLocationRepo(db);
    authEvents = StreamController<AuthState>.broadcast();
  });

  tearDown(() async {
    await authEvents.close();
    await db.close();
  });

  Future<void> insertProfile(String userId) => db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(
          userId: userId,
          h3R7: const Value('871f8d4ffffffff'),
          updatedAt: DateTime.utc(2026, 6, 18, 8),
        ),
      );

  ProviderContainer containerFor(_FakeAuth auth) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authServiceProvider.overrideWith((ref) => auth),
        authStateChangesProvider.overrideWith((ref) => authEvents.stream),
        locationRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(c.dispose);
    // Same wiring as main.dart: without a listener the provider never
    // subscribes to the auth stream, so a sign-in would not rebuild it.
    c.listen(climateRefreshServiceProvider, (_, _) {});
    return c;
  }

  test('a guest with a saved garden is refreshed — no session required', () async {
    // The timezone bins agg_event.local_day for everyone, so gating this on a
    // session (or on kSuggestionsEnabled, which is what N14 did) leaves the
    // column empty for the users who already have a garden.
    await insertProfile(kLocalUserId);
    final c = containerFor(_FakeAuth(kLocalUserId));

    await c.read(climateRefreshServiceProvider.future);

    expect(repo.refreshedFor, [kLocalUserId]);
  });

  test('signing in refreshes again, for the new user id', () async {
    // N14's second half: the refresh used to run once at boot with whatever id
    // existed then — set the garden up as a guest, sign in, and it never ran
    // for the account that the engine actually reads.
    await insertProfile(kLocalUserId);
    await insertProfile('user-1');
    final auth = _FakeAuth(kLocalUserId);
    final c = containerFor(auth);
    await c.read(climateRefreshServiceProvider.future);

    auth._userId = 'user-1';
    authEvents.add(const AuthState(AuthChangeEvent.signedIn, null));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await c.read(climateRefreshServiceProvider.future);

    expect(repo.refreshedFor, [kLocalUserId, 'user-1']);
  });

  test('no profile row at all is a no-op, not a crash', () async {
    final c = containerFor(_FakeAuth(kLocalUserId));

    await c.read(climateRefreshServiceProvider.future);

    expect(repo.refreshedFor, isEmpty);
  });
}
