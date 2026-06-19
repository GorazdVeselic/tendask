import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/auth/data/email_domain_checker.dart';

/// Fake DoH resolver: returns the canned response for the MX query (null =
/// lookup failed). Records queried types so we can assert only MX is queried.
DohResolve _resolver(Map<String, dynamic>? mx, {List<String>? queried}) {
  return (name, type) async {
    queried?.add(type);
    return mx;
  };
}

void main() {
  group('EmailDomainChecker.verify', () {
    test('NXDOMAIN → missing', () async {
      final checker = EmailDomainChecker(_resolver({'Status': 3}));
      expect(await checker.verify('nope.invalid'), DomainVerdict.missing);
    });

    test('NOERROR with MX records → exists, only MX is queried', () async {
      final queried = <String>[];
      final checker = EmailDomainChecker(
        _resolver({
          'Status': 0,
          'Answer': [
            {'type': 15},
          ],
        }, queried: queried),
      );
      expect(await checker.verify('gmail.com'), DomainVerdict.exists);
      expect(queried, ['MX']); // no A/AAAA fallback round-trips
    });

    test('NOERROR but no MX record → exists (resolving domain, fail open)', () async {
      // A domain that resolves without an MX is allowed through; deliverability
      // is the OTP send's problem, not this gate's.
      final checker = EmailDomainChecker(_resolver(const {'Status': 0}));
      expect(await checker.verify('no-mx.example'), DomainVerdict.exists);
    });

    test('lookup failure (null) → unknown (fail open)', () async {
      final checker = EmailDomainChecker(_resolver(null));
      expect(await checker.verify('offline.example'), DomainVerdict.unknown);
    });

    test('SERVFAIL → unknown (fail open)', () async {
      final checker = EmailDomainChecker(_resolver(const {'Status': 2}));
      expect(await checker.verify('broken.example'), DomainVerdict.unknown);
    });

    test('malformed Status (non-int) → unknown (fail open)', () async {
      final checker = EmailDomainChecker(_resolver(const {'Status': 'oops'}));
      expect(await checker.verify('weird.example'), DomainVerdict.unknown);
    });
  });
}
