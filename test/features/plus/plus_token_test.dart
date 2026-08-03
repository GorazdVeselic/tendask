import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/plus/application/plus_token.dart';

// Deterministic test key pair — the real one is generated at ignition (T7) and
// its private half never leaves Supabase secrets.
final _seed = List<int>.generate(32, (i) => i);
final _otherSeed = List<int>.generate(32, (i) => 255 - i);

String _publicKeyOf(List<int> seed) =>
    EdDSAPrivateKey(seed).toJWK()['x'] as String;

final _now = DateTime.utc(2026, 8, 3, 12);
const _uid = '11111111-2222-3333-4444-555555555555';

String _sign({
  String uid = _uid,
  DateTime? until,
  List<int>? seed,
  Map<String, dynamic>? payload,
}) {
  final claims =
      payload ??
      {
        'sub': uid,
        'plus_until':
            (until ?? _now.add(const Duration(days: 30)))
                .millisecondsSinceEpoch ~/
            1000,
      };
  return JWT(claims).sign(
    EdDSAPrivateKey(seed ?? _seed),
    algorithm: JWTAlgorithm.EdDSA,
  );
}

PlusStatus _verify(String? token, {String uid = _uid, String? key, String? kind}) =>
    verifyPlusToken(
      token: token,
      userId: uid,
      nowUtc: _now,
      publicKeyBase64: key ?? _publicKeyOf(_seed),
      kind: kind,
    );

void main() {
  test('a genuine token grants Plus until its signed claim', () {
    final until = DateTime.utc(2027, 2, 1);
    final status = _verify(_sign(until: until), kind: 'granted');

    expect(status.isActive, isTrue);
    expect(status.until, until);
    expect(status.kind, 'granted');
  });

  test('an expired token grants nothing', () {
    final status = _verify(_sign(until: _now.subtract(const Duration(days: 1))));

    expect(status.isActive, isFalse);
    expect(status.until, isNull);
  });

  test('the moment of expiry is already outside the entitlement', () {
    expect(_verify(_sign(until: _now)).isActive, isFalse);
    expect(
      _verify(_sign(until: _now.add(const Duration(seconds: 1)))).isActive,
      isTrue,
    );
  });

  test('a tampered payload breaks the signature', () {
    final parts = _sign().split('.');
    final forged = jsonEncode({
      'sub': _uid,
      'plus_until': DateTime.utc(2099).millisecondsSinceEpoch ~/ 1000,
    });
    final tampered =
        '${parts[0]}.'
        '${base64Url.encode(utf8.encode(forged)).replaceAll('=', '')}.'
        '${parts[2]}';

    expect(_verify(tampered).isActive, isFalse);
  });

  test('a token signed with another key grants nothing', () {
    expect(_verify(_sign(seed: _otherSeed)).isActive, isFalse);
  });

  test('a token issued for someone else grants nothing', () {
    // Copying a friend's row into your drift database must not work.
    expect(_verify(_sign(uid: 'someone-else')).isActive, isFalse);
  });

  test('another algorithm is refused even with a valid signature', () {
    // Alg confusion: the header is attacker-controlled, so EdDSA is pinned
    // before the token ever reaches JWT.verify.
    final hs = JWT({
      'sub': _uid,
      'plus_until': DateTime.utc(2099).millisecondsSinceEpoch ~/ 1000,
    }).sign(SecretKey('secret'));

    expect(_verify(hs).isActive, isFalse);
  });

  test('missing or malformed tokens stay quiet', () {
    // The guest path: no exception, just no Plus.
    expect(_verify(null).isActive, isFalse);
    expect(_verify('').isActive, isFalse);
    expect(_verify('not-a-jwt').isActive, isFalse);
    expect(_verify('a.b.c').isActive, isFalse);
  });

  test('a token without a plus_until claim grants nothing', () {
    expect(_verify(_sign(payload: {'sub': _uid})).isActive, isFalse);
    expect(
      _verify(_sign(payload: {'sub': _uid, 'plus_until': 'soon'})).isActive,
      isFalse,
    );
  });

  test('without a bundled key nothing verifies — the dark state today', () {
    expect(_verify(_sign(), key: '').isActive, isFalse);
    expect(_verify(_sign(), key: 'not-base64!!').isActive, isFalse);
    // Right encoding, wrong length: an Ed25519 key is exactly 32 bytes.
    expect(_verify(_sign(), key: base64.encode([1, 2, 3])).isActive, isFalse);
  });
}
