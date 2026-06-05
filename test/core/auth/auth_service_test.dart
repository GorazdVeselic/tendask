import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tendask/core/auth/auth_service.dart';

void main() {
  // Null client = Supabase not configured (fully offline build). The app must
  // still produce a stable owner id and report no session, never crash.
  test('falls back to kLocalUserId with no client', () {
    final auth = AuthService(null);
    expect(auth.userId, kLocalUserId);
    expect(auth.hasSession, isFalse);
    expect(auth.email, isNull);
  });

  test('email OTP methods throw with no client (offline build)', () async {
    final auth = AuthService(null);
    await expectLater(
        auth.sendEmailOtp('a@b.si'), throwsA(isA<AuthException>()));
    await expectLater(
        auth.verifyEmailOtp('a@b.si', '123456'), throwsA(isA<AuthException>()));
  });
}
