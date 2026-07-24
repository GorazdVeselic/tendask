import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/location/location_service.dart';
import 'package:tendask/features/auth/presentation/location_labels.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('locationErrorLabel', () {
    test('coordinates are not an error', () {
      expect(locationErrorLabel(const LocationCoords(46, 14.5), t), isNull);
    });

    test('each failure gets its own message — the user\'s next move differs', () {
      expect(
        locationErrorLabel(const LocationDenied(permanent: false), t),
        t.location.err_denied,
      );
      expect(
        locationErrorLabel(const LocationServiceDisabled(), t),
        t.location.err_disabled,
      );
      expect(
        locationErrorLabel(const LocationUnavailable(), t),
        t.location.err_unavailable,
      );
    });

    test('a permanently denied permission reads the same as a plain denial', () {
      expect(
        locationErrorLabel(const LocationDenied(permanent: true), t),
        locationErrorLabel(const LocationDenied(permanent: false), t),
      );
    });
  });

  group('locationStatusLabel', () {
    test('not set yet', () {
      expect(
        locationStatusLabel(t, isSet: false),
        t.location.status_unset,
      );
    });

    test('a place name that could not be resolved falls back to plain "set"', () {
      expect(locationStatusLabel(t, isSet: true), t.location.status_set);
    });

    test('a resolved place name is named', () {
      expect(
        locationStatusLabel(t, isSet: true, placeName: 'Kranj'),
        contains('Kranj'),
      );
    });

    test('a place name is ignored while no location is set', () {
      expect(
        locationStatusLabel(t, isSet: false, placeName: 'Kranj'),
        t.location.status_unset,
      );
    });
  });
}
