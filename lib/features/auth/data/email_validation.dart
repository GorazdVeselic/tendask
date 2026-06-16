/// Pure email-input helpers for sign-in hardening (FR-11): format validation and
/// a "did you mean" typo suggestion for the domain. No I/O — domain *existence*
/// is checked separately (DNS-over-HTTPS) in email_domain_checker.dart.
library;

/// Pragmatic email format check (not full RFC 5322 — that's both impossible to
/// regex and stricter than real mailboxes). Requires `local@domain.tld` with a
/// dotted, label-valid domain, and enforces the RFC 5321 length limits.
bool isValidEmailFormat(String email) {
  final e = email.trim();
  if (e.length > 254) return false;
  final at = e.lastIndexOf('@');
  if (at <= 0 || at == e.length - 1) return false;
  if (e.substring(0, at).length > 64) return false;
  return _emailRegex.hasMatch(e);
}

final _emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+"
  r'@'
  r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
  r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
);

/// The lowercased domain part of [email] (after the last `@`), or null if there
/// is no usable domain. Used to feed the DNS check exactly the domain — never
/// the local part — so the lookup can't leak the full address.
String? emailDomain(String email) {
  final e = email.trim();
  final at = e.lastIndexOf('@');
  if (at <= 0 || at == e.length - 1) return null;
  return e.substring(at + 1).toLowerCase();
}

/// A corrected address when [email]'s domain looks like a typo of a common
/// provider (e.g. `gmal.com` → `gmail.com`, `gmail.con` → `gmail.com`), else
/// null. Non-blocking: a suggestion is only a hint; an unusual but real domain
/// (most `.si` business domains) is left untouched. The DNS check is the gate.
String? suggestEmailFix(String email) {
  final e = email.trim();
  final at = e.lastIndexOf('@');
  if (at <= 0 || at == e.length - 1) return null;
  final local = e.substring(0, at);
  final domain = e.substring(at + 1).toLowerCase();
  if (domain.isEmpty || _commonDomains.contains(domain)) return null;

  String? best;
  var bestDistance = 1 << 30;
  for (final candidate in _commonDomains) {
    final d = _damerauLevenshtein(domain, candidate);
    if (d < bestDistance) {
      bestDistance = d;
      best = candidate;
    }
  }
  if (best == null) return null;
  // Distance 1 catches the overwhelming majority (one drop/insert/swap/typo).
  // Allow distance 2 only for longer domains, where two-char slips are common
  // and false positives are unlikely.
  final allowed = best.length >= 9 ? 2 : 1;
  if (bestDistance == 0 || bestDistance > allowed) return null;
  return '$local@$best';
}

/// Common mail providers (incl. the Slovenian market: siol.net, telemach.net,
/// t-2.net, amis.net) used as typo-correction anchors. Add-only — never a gate.
const _commonDomains = <String>{
  'gmail.com',
  'googlemail.com',
  'yahoo.com',
  'yahoo.co.uk',
  'hotmail.com',
  'outlook.com',
  'live.com',
  'msn.com',
  'icloud.com',
  'me.com',
  'aol.com',
  'proton.me',
  'protonmail.com',
  'gmx.de',
  'gmx.net',
  'web.de',
  't-online.de',
  'yandex.com',
  'seznam.cz',
  'siol.net',
  'telemach.net',
  't-2.net',
  'amis.net',
};

/// Damerau-Levenshtein (optimal string alignment) edit distance: like
/// Levenshtein but an adjacent transposition costs 1, so the most common typo
/// (`gmial`/`hotmial`) is caught at distance 1.
int _damerauLevenshtein(String a, String b) {
  final n = a.length;
  final m = b.length;
  if (n == 0) return m;
  if (m == 0) return n;
  final d = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = 0; i <= n; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= m; j++) {
    d[0][j] = j;
  }
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      var v = d[i - 1][j] + 1;
      if (d[i][j - 1] + 1 < v) v = d[i][j - 1] + 1;
      if (d[i - 1][j - 1] + cost < v) v = d[i - 1][j - 1] + cost;
      if (i > 1 &&
          j > 1 &&
          a[i - 1] == b[j - 2] &&
          a[i - 2] == b[j - 1] &&
          d[i - 2][j - 2] + 1 < v) {
        v = d[i - 2][j - 2] + 1;
      }
      d[i][j] = v;
    }
  }
  return d[n][m];
}
