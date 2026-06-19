import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/auth/data/email_validation.dart';

void main() {
  group('isValidEmailFormat', () {
    test('accepts ordinary addresses', () {
      expect(isValidEmailFormat('gorazd@spletnakoda.si'), isTrue);
      expect(isValidEmailFormat('a.b+tag@sub.example.co.uk'), isTrue);
      expect(isValidEmailFormat('  spaced@example.com  '), isTrue);
    });

    test('rejects malformed input', () {
      expect(isValidEmailFormat(''), isFalse);
      expect(isValidEmailFormat('no-at-sign.com'), isFalse);
      expect(isValidEmailFormat('foo@'), isFalse);
      expect(isValidEmailFormat('@example.com'), isFalse);
      expect(isValidEmailFormat('foo@bar'), isFalse); // no TLD dot
      expect(isValidEmailFormat('foo@bar.'), isFalse);
      expect(isValidEmailFormat('foo @example.com'), isFalse);
    });

    test('enforces length limits', () {
      final longLocal = '${'a' * 65}@example.com';
      expect(isValidEmailFormat(longLocal), isFalse);
      final longTotal = '${'a' * 250}@example.com';
      expect(isValidEmailFormat(longTotal), isFalse);
    });
  });

  group('emailDomain', () {
    test('returns the lowercased domain', () {
      expect(emailDomain('Foo@Gmail.COM'), 'gmail.com');
      expect(emailDomain('a@b@example.com'), 'example.com');
    });

    test('returns null without a domain', () {
      expect(emailDomain('foo'), isNull);
      expect(emailDomain('foo@'), isNull);
      expect(emailDomain('@x.com'), isNull);
    });
  });

  group('suggestEmailFix', () {
    test('corrects common one-edit domain typos', () {
      expect(suggestEmailFix('jan@gmal.com'), 'jan@gmail.com'); // deletion
      expect(suggestEmailFix('jan@gmial.com'), 'jan@gmail.com'); // transposition
      expect(suggestEmailFix('jan@gmail.con'), 'jan@gmail.com'); // tld typo
      expect(suggestEmailFix('jan@hotmial.com'), 'jan@hotmail.com');
      expect(suggestEmailFix('jan@outlok.com'), 'jan@outlook.com');
    });

    test('keeps the local part verbatim', () {
      expect(suggestEmailFix('a.b+x@gmal.com'), 'a.b+x@gmail.com');
    });

    test('returns null for already-correct common domains', () {
      expect(suggestEmailFix('jan@gmail.com'), isNull);
      expect(suggestEmailFix('jan@siol.net'), isNull);
    });

    test('returns null for unrelated/real domains (no false positives)', () {
      expect(suggestEmailFix('info@spletnakoda.si'), isNull);
      expect(suggestEmailFix('a@company.example'), isNull);
      expect(suggestEmailFix('foo'), isNull);
    });
  });
}
