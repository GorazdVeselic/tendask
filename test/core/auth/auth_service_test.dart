import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';

void main() {
  // Null client = Supabase not configured (fully offline build). The app must
  // still produce a stable owner id and report no session, never crash.
  test('falls back to kLocalUserId with no client', () {
    final auth = AuthService(null);
    expect(auth.userId, kLocalUserId);
    expect(auth.hasSession, isFalse);
  });

  test('ensureAnonymousSession is a no-op with no client', () async {
    await AuthService(null).ensureAnonymousSession();
  });
}
