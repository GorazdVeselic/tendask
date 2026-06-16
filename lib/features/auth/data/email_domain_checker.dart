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

/// Checks whether an email domain can plausibly receive mail, using Google's
/// DNS-over-HTTPS resolver. Privacy: only the bare *domain* is sent — never the
/// local part, so the lookup can't reveal the full address.
///
/// Conservative by design: it returns [DomainVerdict.missing] ONLY for a
/// definitive NXDOMAIN, or when MX, A and AAAA all resolve cleanly with no
/// records (a domain that exists but cannot receive mail). Any inconclusive
/// result is [DomainVerdict.unknown] → the caller proceeds (fail-open).
class EmailDomainChecker {
  EmailDomainChecker(this._resolve);

  final DohResolve _resolve;

  Future<DomainVerdict> verify(String domain) async {
    final mx = await _resolve(domain, 'MX');
    if (mx == null) return DomainVerdict.unknown; // lookup failed → fail open
    final mxStatus = _status(mx);
    if (mxStatus == _nxdomain) return DomainVerdict.missing;
    if (mxStatus != _noerror) return DomainVerdict.unknown; // SERVFAIL, etc.
    if (_hasAnswer(mx)) return DomainVerdict.exists;

    // No MX record: fall back to A/AAAA — RFC 5321 §5.1 treats an address record
    // as an implicit MX. Each query must resolve cleanly to count as negative.
    final a = await _resolve(domain, 'A');
    final aVerdict = _addressVerdict(a);
    if (aVerdict != null) return aVerdict; // exists or unknown (inconclusive)

    final aaaa = await _resolve(domain, 'AAAA');
    final aaaaVerdict = _addressVerdict(aaaa);
    if (aaaaVerdict != null) return aaaaVerdict;

    // NOERROR with no MX, A or AAAA — definitively cannot receive mail.
    return DomainVerdict.missing;
  }

  /// exists (has records) / unknown (lookup inconclusive) / null = "clean but
  /// empty, keep checking the next record type".
  DomainVerdict? _addressVerdict(Map<String, dynamic>? res) {
    if (res == null) return DomainVerdict.unknown;
    final status = _status(res);
    if (status == _noerror && _hasAnswer(res)) return DomainVerdict.exists;
    if (status != _noerror && status != _nxdomain) return DomainVerdict.unknown;
    return null;
  }

  static const _noerror = 0;
  static const _nxdomain = 3;

  int? _status(Map<String, dynamic> res) {
    final s = res['Status'];
    return s is int ? s : null;
  }

  bool _hasAnswer(Map<String, dynamic> res) {
    final answer = res['Answer'];
    return answer is List && answer.isNotEmpty;
  }
}

/// Dedicated short-timeout Dio for the DoH lookup (independent of the weather
/// client's longer budget): the check is a sign-in pre-flight and must stay snappy.
@riverpod
Dio dnsDio(Ref ref) => Dio(
  BaseOptions(
    connectTimeout: kDnsCheckTimeout,
    receiveTimeout: kDnsCheckTimeout,
    headers: const {'accept': 'application/dns-json'},
  ),
);

@riverpod
EmailDomainChecker emailDomainChecker(Ref ref) {
  final dio = ref.watch(dnsDioProvider);
  return EmailDomainChecker((name, type) async {
    try {
      final res = await dio.get<Map<String, dynamic>>(
        'https://dns.google/resolve',
        queryParameters: {'name': name, 'type': type},
      );
      return res.data;
    } on Object {
      return null; // offline / timeout / bad body → fail open
    }
  });
}
