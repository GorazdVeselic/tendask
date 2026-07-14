import '../../../core/location/location_service.dart';
import '../../../i18n/translations.g.dart';

/// The message for a GPS attempt that brought no coordinates; null on success.
/// Each failure reads differently because the user's next move differs: grant the
/// permission, switch location on, or simply try again.
String? locationErrorLabel(LocationResult result, Translations t) =>
    switch (result) {
      LocationCoords() => null,
      LocationDenied() => t.location.err_denied,
      LocationServiceDisabled() => t.location.err_disabled,
      LocationUnavailable() => t.location.err_unavailable,
    };

/// The status banner's line: not set yet, set at a resolved place, or set but
/// with the place name still unresolved (offline).
String locationStatusLabel(
  Translations t, {
  required bool isSet,
  String? placeName,
}) {
  if (!isSet) return t.location.status_unset;
  if (placeName != null) return t.location.status_set_at(name: placeName);
  return t.location.status_set;
}
