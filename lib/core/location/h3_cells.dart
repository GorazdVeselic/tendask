import 'package:h3_flutter/h3_flutter.dart';

/// The three H3 cells derived from a coordinate: res-7 (finest we store) plus
/// its res-6 and res-5 parents for V2 neighbourhood roll-ups (§5/§7.14). Stored
/// as canonical lowercase hex strings — the same form Postgres/text columns use.
typedef H3Cells = ({String r7, String r6, String r5});

/// Derives the H3 cells for [lat]/[lon] on-device. The caller persists only
/// these cells (raw coordinates never leave the device — privacy by design).
H3Cells deriveH3Cells(H3 h3, double lat, double lon) {
  final cell7 = h3.geoToCell(GeoCoord(lat: lat, lon: lon), 7);
  return (
    r7: cell7.toRadixString(16),
    r6: h3.cellToParent(cell7, 6).toRadixString(16),
    r5: h3.cellToParent(cell7, 5).toRadixString(16),
  );
}
