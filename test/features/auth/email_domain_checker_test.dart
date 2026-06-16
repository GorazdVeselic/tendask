import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/auth/data/email_domain_checker.dart';

/// Builds a fake DoH resolver from a map of `type → response` (null = lookup
/// failed). Records every queried type so tests can assert the fallback order.
DohResolve _resolver(
  Map<String, Map<String, dynamic>?> byType, {
  List<String>? queried,
}) {
  return (name, type) async {
    queried?.add(type);
    return byType[type];
  };
}

Map<String, dynamic> _noerrorWith(List<Object> answer) => {
  'Status': 0,
  'Answer': answer,
};
const _noerrorEmpty = {'Status': 0};
const _nxdomain = {'Status': 3};
const _servfail = {'Status': 2};

void main() {
  group('EmailDomainChecker.verify', () {
    test('MX present → exists (no A/AAAA fallback)', () async {
      final queried = <String>[];
      final checker = EmailDomainChecker(
        _resolver({
          'MX': _noerrorWith([
            {'type': 15},
          ]),
        }, queried: queried),
      );
      expect(await checker.verify('gmail.com'), DomainVerdict.exists);
      expect(queried, ['MX']);
    });

    test('NXDOMAIN → missing', () async {
      final checker = EmailDomainChecker(_resolver({'MX': _nxdomain}));
      expect(await checker.verify('nope.invalid'), DomainVerdict.missing);
    });

    test('no MX but A record → exists (implicit MX)', () async {
      final queried = <String>[];
      final checker = EmailDomainChecker(
        _resolver({
          'MX': _noerrorEmpty,
          'A': _noerrorWith([
            {'type': 1},
          ]),
        }, queried: queried),
      );
      expect(await checker.verify('example.com'), DomainVerdict.exists);
      expect(queried, ['MX', 'A']);
    });

    test('no MX/A but AAAA record → exists', () async {
      final checker = EmailDomainChecker(
        _resolver({
          'MX': _noerrorEmpty,
          'A': _noerrorEmpty,
          'AAAA': _noerrorWith([
            {'type': 28},
          ]),
        }),
      );
      expect(await checker.verify('v6.example'), DomainVerdict.exists);
    });

    test('NOERROR but no MX/A/AAAA → missing', () async {
      final checker = EmailDomainChecker(
        _resolver({
          'MX': _noerrorEmpty,
          'A': _noerrorEmpty,
          'AAAA': _noerrorEmpty,
        }),
      );
      expect(await checker.verify('records-less.example'), DomainVerdict.missing);
    });

    test('lookup failure (null) → unknown (fail open)', () async {
      final checker = EmailDomainChecker(_resolver({'MX': null}));
      expect(await checker.verify('offline.example'), DomainVerdict.unknown);
    });

    test('SERVFAIL on MX → unknown (fail open)', () async {
      final checker = EmailDomainChecker(_resolver({'MX': _servfail}));
      expect(await checker.verify('broken.example'), DomainVerdict.unknown);
    });

    test('A lookup fails after empty MX → unknown (no false block)', () async {
      final checker = EmailDomainChecker(
        _resolver({'MX': _noerrorEmpty, 'A': null}),
      );
      expect(await checker.verify('maybe.example'), DomainVerdict.unknown);
    });
  });
}
