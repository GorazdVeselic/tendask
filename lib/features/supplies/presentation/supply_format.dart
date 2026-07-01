/// Formats a supply quantity or amount for display: drops a trailing ".0" so
/// whole numbers read cleanly. With [clampNegative] a deficit (negative stock
/// from over-consumption) shows as 0 — the signed value stays in the DB for
/// symmetric revert, only the display clamps.
String formatSupplyQuantity(double v, {bool clampNegative = false}) {
  final c = clampNegative && v < 0 ? 0.0 : v;
  return c == c.roundToDouble() ? c.toInt().toString() : c.toString();
}
