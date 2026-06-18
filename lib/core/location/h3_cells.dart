import 'package:h3_flutter/h3_flutter.dart';

/// H3 resolutions we work with: res-7 is the finest we store (~1.2 km edge);
/// res-6/res-5 parents are kept for V2 neighbourhood roll-ups (§5/§7.14).
const int kH3ResR7 = 7;
const int kH3ResR6 = 6;
const int kH3ResR5 = 5;

/// A garden coordinate pair (degrees), used only for the weather lookup. Since
/// FR-8 it is the centroid of the stored r7 cell, never a raw GPS fix.
typedef GardenCoords = ({double latitude, double longitude});

/// The three H3 cells derived from a coordinate: res-7 (finest we store) plus
/// its res-6 and res-5 parents for V2 neighbourhood roll-ups (§5/§7.14). Stored
/// as canonical lowercase hex strings — the same form Postgres/text columns use.
typedef H3Cells = ({String r7, String r6, String r5});

/// Derives the H3 cells for [lat]/[lon] on-device. The caller persists only
/// these cells (raw coordinates never leave the device — privacy by design).
H3Cells deriveH3Cells(H3 h3, double lat, double lon) {
  final cell7 = h3.geoToCell(GeoCoord(lat: lat, lon: lon), kH3ResR7);
  return (
    r7: cell7.toRadixString(16),
    r6: h3.cellToParent(cell7, kH3ResR6).toRadixString(16),
    r5: h3.cellToParent(cell7, kH3ResR5).toRadixString(16),
  );
}

/// Centroid of an H3 cell given as canonical lowercase hex (profile.h3_r7).
/// Privacy by design: this round-trips through the stored cell, so the weather
/// lookup uses an approximate point (≤ ~1.4 km from the garden), never a raw
/// GPS fix. Returns null when [hexCell] is null/empty/unparseable, so callers
/// fall back to the default region instead of crashing.
GardenCoords? cellCentroid(H3 h3, String? hexCell) {
  if (hexCell == null || hexCell.isEmpty) return null;
  final cell = BigInt.tryParse(hexCell, radix: 16);
  if (cell == null) return null;
  final c = h3.cellToGeo(cell);
  return (latitude: c.lat, longitude: c.lon);
}
