import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

part 'auth_service.g.dart';

/// Owner id for a guest's rows: the app stays fully local until the user signs
/// in (no anonymous cloud account is ever created). Claimed to the real
/// auth.uid() on sign-in — see claimLocalRows.
const kLocalUserId = 'local';

/// Thin wrapper over Supabase auth. A null client means Supabase was not
/// configured (fully offline build) → everything falls back to [kLocalUserId].
///
/// Guests have no cloud session: the app reads/writes drift under [kLocalUserId]
/// and only creates a real account when the user signs in with email/Google.
/// At that point claimLocalRows re-owns the guest's rows to the new uid and they
/// sync up — so signing in keeps the guest's data (a merge, never a reset).
class AuthService {
  AuthService(this._client);

  final SupabaseClient? _client;

  /// [GoogleSignIn.instance] must be initialized exactly once before use.
  bool _googleInitialized = false;

  /// Owner id for new rows: the real auth.uid() when signed in, else
  /// [kLocalUserId]. Reads the live client so callers always see the current
  /// value (a session appears after a sign-in completes).
  String get userId => _client?.auth.currentUser?.id ?? kLocalUserId;

  bool get hasSession => _client?.auth.currentUser != null;

  /// The signed-in email, or null for a guest / offline build. Doubles as a
  /// "signed in" signal (a guest has no session and therefore no email).
  String? get email => _client?.auth.currentUser?.email;

  /// Ends the current session → back to a local guest. The caller flushes any
  /// pending push first, then clears local data (sign-out + reset).
  Future<void> signOut() async => _client?.auth.signOut();

  /// Sends an OTP to [email] — creates the account if new, else signs into the
  /// existing one. After verifying, the caller claims the guest's local rows to
  /// this account and syncs, so the device's data is kept (merged), not lost.
  /// Requires connectivity; throws [AuthException] when unavailable.
  Future<void> sendEmailOtp(String email) async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    await client.auth.signInWithOtp(email: email);
  }

  /// Verifies the OTP [token] for [email], establishing the session.
  Future<void> verifyEmailOtp(String email, String token) async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    await client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  /// Native Google sign-in (M7.4): obtains a Google ID token and exchanges it
  /// for a Supabase session. Returns false if the user cancels the picker (not
  /// an error); throws [AuthException] on a real failure or missing config. The
  /// caller then claims the guest's local rows and syncs (sign-in keeps data).
  Future<bool> signInWithGoogle() async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    if (kGoogleServerClientId.isEmpty) {
      throw const AuthException('Google sign-in is not configured');
    }
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: kGoogleServerClientId,
      );
      _googleInitialized = true;
    }
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google sign-in returned no ID token');
      }
      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return true;
    } on GoogleSignInException catch (e) {
      // User dismissed the picker — a normal outcome, not an error to surface.
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      throw AuthException('Google sign-in failed: ${e.description ?? e.code}');
    }
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  // Supabase.instance throws when initialize() was skipped (no config).
  final client = kSupabaseUrl.isEmpty ? null : Supabase.instance.client;
  return AuthService(client);
}

/// Emits on sign-in/out/email-link so auth-dependent UI (e.g. settings profile)
/// rebuilds. Empty stream on an offline build (no Supabase configured).
@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  if (kSupabaseUrl.isEmpty) return const Stream.empty();
  return Supabase.instance.client.auth.onAuthStateChange;
}
