import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// Outcome of a one-shot device-location request. Models the permission states
/// the UI must tell apart: coordinates obtained, denied (can re-ask), denied
/// forever (needs system settings), location services off, or no fix. The
/// garden may have no GPS — the UI always offers manual place entry as fallback.
sealed class LocationResult {
  const LocationResult();
}

class LocationCoords extends LocationResult {
  const LocationCoords(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationDenied extends LocationResult {
  const LocationDenied({required this.permanent});

  /// True when the OS will no longer prompt — the user must enable it in the
  /// system settings, so the UI shows that hint instead of re-asking.
  final bool permanent;
}

class LocationServiceDisabled extends LocationResult {
  const LocationServiceDisabled();
}

class LocationUnavailable extends LocationResult {
  const LocationUnavailable();
}

/// One-shot device location via geolocator. Medium accuracy is intentional: we
/// only derive an H3 res-7 cell (~1 km wide), so a precise fix wastes battery.
/// Raw coordinates never leave the device — only the H3 cell is stored/synced.
class LocationService {
  const LocationService();

  Future<LocationResult> currentCoordinates() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationServiceDisabled();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationDenied(permanent: true);
    }
    if (permission == LocationPermission.denied) {
      return const LocationDenied(permanent: false);
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return LocationCoords(pos.latitude, pos.longitude);
    } on Exception {
      // Timeout / transient platform error — the garden may have no fix.
      return const LocationUnavailable();
    }
  }
}

@riverpod
LocationService locationService(Ref ref) => const LocationService();
