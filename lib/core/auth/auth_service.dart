import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

part 'auth_service.g.dart';

/// Owner id for rows created before the first sign-in (offline-first: the garden
/// may have no signal on first launch). Claimed to the real auth.uid() once a
/// session exists — see claimLocalRows.
const kLocalUserId = 'local';

/// Thin wrapper over Supabase auth. A null client means Supabase was not
/// configured (fully offline build) → everything falls back to [kLocalUserId].
class AuthService {
  AuthService(this._client);

  final SupabaseClient? _client;

  /// Owner id for new rows: the real auth.uid() when signed in, else
  /// [kLocalUserId]. Reads the live client so callers always see the current
  /// value (a session may appear after an async anonymous sign-in).
  String get userId => _client?.auth.currentUser?.id ?? kLocalUserId;

  bool get hasSession => _client?.auth.currentUser != null;

  /// The signed-in email, or null for a guest (anonymous) / offline build.
  /// Anonymous sessions have no email, so this doubles as a "signed in" signal.
  String? get email => _client?.auth.currentUser?.email;

  /// Signs in anonymously when configured and not already signed in. Offline is
  /// a no-op: the app stays on [kLocalUserId] and a later sync trigger (M6.4)
  /// retries; local rows are claimed once a session exists.
  Future<void> ensureAnonymousSession() async {
    final client = _client;
    if (client == null || client.auth.currentUser != null) return;
    try {
      await client.auth.signInAnonymously();
    } on AuthException catch (_) {
      // Network down / auth unreachable — expected offline; stay on
      // kLocalUserId. M6.4 retries; rows are claimed once a session exists.
    }
  }

  /// Ends the current session. The caller clears local data and starts a fresh
  /// anonymous session afterwards (sign-out + reset to clean state).
  Future<void> signOut() async => _client?.auth.signOut();

  // ---- Link an email to the current anonymous session (keeps data) ----

  /// Sends an OTP to [email] to upgrade the current (anonymous) session to a
  /// permanent email account. Uses updateUser (not signInWithOtp) so the user
  /// id is preserved — the local data claimed to the anonymous uid stays.
  /// Requires connectivity; throws [AuthException] when unavailable.
  Future<void> sendLinkOtp(String email) async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    await ensureAnonymousSession();
    await client.auth.updateUser(UserAttributes(email: email));
  }

  /// Verifies the OTP [token] for the email-link flow (emailChange).
  Future<void> verifyLinkOtp(String email, String token) async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    await client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.emailChange,
    );
  }

  // ---- Sign in with an email account (new or returning) ----

  /// Sends an OTP to sign in to [email] — creates the account if new, else signs
  /// into the existing one. After verifying, the caller clears the previous
  /// (anonymous) session's local rows, then pulls this account's data.
  Future<void> sendSignInOtp(String email) async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    await client.auth.signInWithOtp(email: email);
  }

  /// Verifies the OTP [token] for the sign-in flow (email), switching the
  /// session to that account.
  Future<void> verifySignInOtp(String email, String token) async {
    final client = _client;
    if (client == null) throw const AuthException('Auth not configured');
    await client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
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
