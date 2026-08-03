import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/features/plus/application/plus_provider.dart';
import 'package:tendask/features/plus/application/plus_token.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

final _seed = List<int>.generate(32, (i) => i);
final _publicKey = EdDSAPrivateKey(_seed).toJWK()['x'] as String;
final _now = DateTime.utc(2026, 8, 3, 12);

String _token({String uid = kLocalUserId, DateTime? until}) => JWT({
  'sub': uid,
  'plus_until':
      (until ?? _now.add(const Duration(days: 30))).millisecondsSinceEpoch ~/
      1000,
}).sign(EdDSAPrivateKey(_seed), algorithm: JWTAlgorithm.EdDSA);

typedef _Env = ({ProviderContainer container, AppDatabase db});

_Env _setup({DateTime? now, String? publicKey}) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      // No cloud session → the guest user id, exactly like a fresh install.
      authServiceProvider.overrideWithValue(AuthService(null)),
      plusClockProvider.overrideWithValue(_FixedClock(now ?? _now)),
      plusPublicKeyProvider.overrideWithValue(publicKey ?? _publicKey),
    ],
  );
  // LIFO: dispose the container (cancels the profile stream) before the
  // database closes, or `db.close()` waits on a live subscription.
  addTearDown(() => db.close());
  addTearDown(container.dispose);
  return (container: container, db: db);
}

Future<void> _writeProfile(
  AppDatabase db, {
  String? token,
  DateTime? until,
  String? kind,
}) => db
    .into(db.profiles)
    .insert(
      ProfilesCompanion.insert(
        userId: kLocalUserId,
        plusToken: Value(token),
        plusUntil: Value(until),
        plusKind: Value(kind),
        updatedAt: _now,
      ),
    );

Future<PlusStatus> _status(_Env env) {
  // A stream provider only subscribes once someone listens.
  addTearDown(env.container.listen(plusProvider, (_, _) {}).close);
  return env.container.read(plusProvider.future);
}

void main() {
  test('a guest without a profile row is quietly not Plus', () async {
    final env = _setup();

    final status = await _status(env);

    expect(status.isActive, isFalse);
    expect(status.until, isNull);
  });

  test('a pulled token unlocks Plus and carries the display kind', () async {
    final env = _setup();
    final until = DateTime.utc(2027, 2, 1);
    await _writeProfile(
      env.db,
      token: _token(until: until),
      until: until,
      kind: 'granted',
    );

    final status = await _status(env);

    expect(status.isActive, isTrue);
    expect(status.until, until);
    expect(status.kind, 'granted');
  });

  test('editing plus_until in drift buys nothing without a token', () async {
    // The whole point of the signature: the column is not the authority.
    final env = _setup();
    await _writeProfile(env.db, until: DateTime.utc(2099), kind: 'lifetime');

    expect((await _status(env)).isActive, isFalse);
  });

  test('a stretched plus_until column cannot outlive the signed claim', () async {
    final env = _setup();
    await _writeProfile(
      env.db,
      token: _token(until: _now.subtract(const Duration(days: 1))),
      until: DateTime.utc(2099),
    );

    expect((await _status(env)).isActive, isFalse);
  });

  test('the clock decides expiry, not the moment of the pull', () async {
    final until = _now.add(const Duration(days: 2));
    final env = _setup(now: until.add(const Duration(minutes: 1)));
    await _writeProfile(env.db, token: _token(until: until), until: until);

    expect((await _status(env)).isActive, isFalse);
  });

  test('a token minted for another account never applies', () async {
    final env = _setup();
    await _writeProfile(env.db, token: _token(uid: 'someone-else'));

    expect((await _status(env)).isActive, isFalse);
  });

  test('Plus follows the row: revoking the token switches it off', () async {
    final env = _setup();
    await _writeProfile(env.db, token: _token());
    expect((await _status(env)).isActive, isTrue);

    await (env.db.update(
      env.db.profiles,
    )..where((p) => p.userId.equals(kLocalUserId))).write(
      const ProfilesCompanion(plusToken: Value(null)),
    );
    await pumpEventQueue();

    expect(env.container.read(plusProvider).value?.isActive, isFalse);
  });

  test('the shipped build carries no key yet, so nothing unlocks', () async {
    // Guards the dark state: until T7 generates the pair, kPlusPublicKey is
    // empty and even a genuine token grants nothing.
    final env = _setup(publicKey: '');
    await _writeProfile(env.db, token: _token());

    expect((await _status(env)).isActive, isFalse);
  });
}
