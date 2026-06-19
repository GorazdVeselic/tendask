import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config.dart';

part 'email_domain_checker.g.dart';

/// Verdict of the domain-existence check (FR-11). Only [missing] is a definitive
/// negative the UI may block on; [unknown] means the lookup was inconclusive
/// (offline, timeout, server error) and MUST fail open — never block sign-in.
enum DomainVerdict { exists, missing, unknown }

/// Resolves a DNS [name]/[type] via DNS-over-HTTPS and returns the parsed JSON,
/// or null on any failure (so the checker can fail open). Injected for testing.
typedef DohResolve =
    Future<Map<String, dynamic>?> Function(String name, String type);

/// Checks whether an email domain exists, using Google's DNS-over-HTTPS
/// resolver. Privacy: only the bare *domain* is sent — never the local part, so
/// the lookup can't reveal the full address.
///
/// Conservative and fail-open by design: returns [DomainVerdict.missing] ONLY
/// for a definitive NXDOMAIN (the domain genuinely does not exist). A domain
/// that resolves is [exists] even without an MX record — mail may still arrive
/// via the A/AAAA fallback (RFC 5321 §5.1) or the address is simply unusual;
/// catching "exists but can't receive mail" is left to the OTP send and the
/// typo suggestion, not this gate. Any inconclusive lookup (offline, timeout,
/// SERVFAIL) is [unknown] → the caller proceeds. This keeps the check from ever
/// false-blocking a real address.
class EmailDomainChecker {
  EmailDomainChecker(this._resolve);

  final DohResolve _resolve;

  Future<DomainVerdict> verify(String domain) async {
    // One MX query is enough: its Status alone tells us whether the domain
    // exists. We don't inspect the records — a resolving domain is allowed
    // through regardless of MX presence (fail open).
    final res = await _resolve(domain, 'MX');
    if (res == null) return DomainVerdict.unknown; // lookup failed → fail open
    switch (_status(res)) {
      case _nxdomain:
        return DomainVerdict.missing; // domain does not exist
      case _noerror:
        return DomainVerdict.exists; // resolves (with or without MX records)
      default:
        return DomainVerdict.unknown; // SERVFAIL / refused / malformed
    }
  }

  static const _noerror = 0;
  static const _nxdomain = 3;

  int? _status(Map<String, dynamic> res) {
    final s = res['Status'];
    return s is int ? s : null;
  }
}

/// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
/// client's longer budget): the check is a sign-in pre-flight and must stay snappy.
/// keepAlive: the screen reads the checker one-shot (no listener), so an
/// autoDispose Dio would be closed by ref.onDispose the instant the read returns —
/// before the async lookup runs — killing every check. One long-lived client.
@Riverpod(keepAlive: true)
Dio dnsDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: kDnsCheckTimeout,
      receiveTimeout: kDnsCheckTimeout,
      headers: const {'accept': 'application/dns-json'},
    ),
  );
  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
EmailDomainChecker emailDomainChecker(Ref ref) {
  final dio = ref.watch(dnsDioProvider);
  return EmailDomainChecker((name, type) async {
    try {
      // Read the raw body and decode it ourselves rather than relying on Dio's
      // content-type-gated auto-decode: dns.google currently answers with
      // application/json, but if it ever switched to the RFC application/dns-json
      // Dio would silently hand back a String and the check would become a no-op.
      final res = await dio.get<String>(
        'https://dns.google/resolve',
        queryParameters: {'name': name, 'type': type},
        options: Options(responseType: ResponseType.plain),
      );
      final body = res.data;
      if (body == null || body.isEmpty) return null;
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on Object {
      return null; // offline / timeout / bad body → fail open
    }
  });
}
