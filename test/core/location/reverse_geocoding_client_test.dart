import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/location/reverse_geocoding_client.dart';

void main() {
  group('pickPlaceName', () {
    test('prefers a village over coarser admin areas', () {
      expect(
        pickPlaceName({
          'address': {
            'village': 'Trzin',
            'municipality': 'Domžale',
            'county': 'Osrednjeslovenska',
            'country': 'Slovenija',
          },
        }),
        'Trzin',
      );
    });

    test('falls through the specificity order (town, then city)', () {
      expect(
        pickPlaceName({
          'address': {'town': 'Kamnik', 'city': 'Ljubljana'},
        }),
        'Kamnik',
      );
      expect(
        pickPlaceName({
          'address': {'city': 'Ljubljana', 'county': 'Osrednjeslovenska'},
        }),
        'Ljubljana',
      );
    });

    test('uses the coarse municipality only as a last resort', () {
      expect(
        pickPlaceName({
          'address': {'municipality': 'Domžale', 'state': 'Slovenija'},
        }),
        'Domžale',
      );
    });

    test('falls back to the top-level name when address has no settlement', () {
      expect(
        pickPlaceName({
          'name': 'Triglav',
          'address': {'country': 'Slovenija'},
        }),
        'Triglav',
      );
    });

    test('trims surrounding whitespace', () {
      expect(
        pickPlaceName({
          'address': {'village': '  Trzin  '},
        }),
        'Trzin',
      );
    });

    test('returns null for a null body, empty address, or blank values', () {
      expect(pickPlaceName(null), isNull);
      expect(pickPlaceName({'address': <String, dynamic>{}}), isNull);
      expect(
        pickPlaceName({
          'address': {'village': '   '},
        }),
        isNull,
      );
    });
  });
}
