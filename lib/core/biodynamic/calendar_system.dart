/// Zodiac division used to derive the day's element (FR-19 spec §13/§14.5).
enum CalendarSystem {
  /// Unequal visible constellations, calibrated boundaries (default; §14.5).
  sidereal,

  /// Equal 30-degree signs, `floor(lambda / 30)` (comparison with web sources).
  tropical,
}
