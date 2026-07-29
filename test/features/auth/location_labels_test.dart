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

    test(
      'each failure gets its own message — the user\'s next move differs',
      () {
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
      },
    );

    test(
      'a permanently denied permission reads the same as a plain denial',
      () {
        expect(
          locationErrorLabel(const LocationDenied(permanent: true), t),
          locationErrorLabel(const LocationDenied(permanent: false), t),
        );
      },
    );
  });
}
