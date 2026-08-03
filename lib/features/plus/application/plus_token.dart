import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Tendask+ entitlement as derived from the signed token (FR-20 §6.2).
class PlusStatus {
  const PlusStatus.none() : isActive = false, until = null, kind = null;

  const PlusStatus.active({required DateTime this.until, this.kind})
    : isActive = true;

  final bool isActive;

  /// End of the entitlement, straight from the signed claim (UTC).
  final DateTime? until;

  /// Display text only ("lifetime" vs "until …"), taken from the unsigned
  /// column — it must never widen what [isActive] allows.
  final String? kind;

  @override
  bool operator ==(Object other) =>
      other is PlusStatus &&
      other.isActive == isActive &&
      other.until == until &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(isActive, until, kind);

  @override
  String toString() =>
      'PlusStatus(isActive: $isActive, until: $until, kind: $kind)';
}

/// Verifies the entitlement token offline and returns what it grants.
///
/// The token is the only authority: a hand-edited `plus_until` column is not
/// covered by the signature, so tampering with the local drift row cannot
/// unlock anything. Anything unexpected — missing key, wrong algorithm, foreign
/// `sub`, malformed or expired token — is a quiet [PlusStatus.none], never an
/// exception: a guest offline must not see an error, just no Plus.
///
/// Token contract (issued by the server, FR-20 §6.2):
/// `{ "sub": <uid>, "plus_until": <epoch seconds>, "iat": <epoch seconds> }`
/// signed with EdDSA/Ed25519.
PlusStatus verifyPlusToken({
  required String? token,
  required String userId,
  required DateTime nowUtc,
  required String publicKeyBase64,
  String? kind,
}) {
  if (token == null || token.isEmpty || publicKeyBase64.isEmpty) {
    return const PlusStatus.none();
  }

  try {
    final keyBytes = base64.decode(base64.normalize(publicKeyBase64));
    if (keyBytes.length != 32) return const PlusStatus.none();

    // JWT.verify takes the algorithm from the token header, so pin it here
    // instead: a token claiming another algorithm must never reach verify.
    if (JWT.decode(token).header?['alg'] != 'EdDSA') {
      return const PlusStatus.none();
    }

    final jwt = JWT.verify(
      token,
      EdDSAPublicKey(keyBytes),
      // The algorithm is pinned above, so `typ` adds nothing — and an issuer
      // that omits it would switch Plus off with no visible cause.
      checkHeaderType: false,
      // Expiry is judged below against the injected clock, not the package's
      // ambient one, so that a test can travel past it.
      checkExpiresIn: false,
      checkNotBefore: false,
    );

    final payload = jwt.payload;
    if (payload is! Map) return const PlusStatus.none();
    if (payload['sub'] != userId) return const PlusStatus.none();

    final claim = payload['plus_until'];
    if (claim is! num) return const PlusStatus.none();
    final until = DateTime.fromMillisecondsSinceEpoch(
      (claim * 1000).round(),
      isUtc: true,
    );
    if (!nowUtc.toUtc().isBefore(until)) return const PlusStatus.none();

    return PlusStatus.active(until: until, kind: kind);
  } catch (_) {
    return const PlusStatus.none();
  }
}
