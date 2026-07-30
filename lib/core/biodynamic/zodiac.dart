import 'biodynamic_day.dart';

/// Precession drift of tropical longitudes, degrees per year.
const kPrecessionDegPerYear = 0.013972;

/// Traditional biodynamic constellation boundaries (calibrated): tropical
/// longitude where each constellation begins, Aries..Pisces, epoch 2024.0.
/// Values, derivation and legal rationale: boundaries doc §1–§3. Ophiuchus
/// is absorbed into the Scorpio band.
const kCalibratedStarts = [
  29.8, // Ari
  54.1, // Tau
  90.1, // Gem
  118.1, // Cnc
  139.1, // Leo
  174.0, // Vir
  220.0, // Lib
  238.1, // Sco
  269.1, // Sgr
  299.2, // Cap
  327.1, // Aqr
  352.1, // Psc
];
const kCalibratedEpochYear = 2024;

/// IAU constellation boundaries (fallback table, boundaries doc §4): derived
/// from Sun entry dates, epoch 2000.0; Ophiuchus folded into Scorpio.
const kIauStarts = [
  28.7647, // Ari
  53.0342, // Tau
  90.4182, // Gem
  118.0758, // Cnc
  138.1647, // Leo
  173.9317, // Vir
  217.3835, // Lib
  241.5179, // Sco (through Ophiuchus)
  265.8730, // Sgr
  299.7407, // Cap
  327.1289, // Aqr
  351.2324, // Psc
];
const kIauEpochYear = 2000;

// Active sidereal table; emergency exit (boundaries doc §4) = point these
// two at the IAU constants. Nothing else changes.
const _activeStarts = kCalibratedStarts;
const _activeEpochYear = kCalibratedEpochYear;

/// Tropical sign for ecliptic longitude [lambda]: equal 30-degree bands.
ZodiacSign tropicalSignFor(double lambda) =>
    ZodiacSign.values[(lambda % 360) ~/ 30];

/// Sidereal constellation for tropical ecliptic longitude [lambda] in [year].
///
/// Boundaries are fixed to the stars, so their tropical longitude drifts by
/// precession; comparing the precession-shifted longitude against the epoch
/// table is equivalent to shifting all twelve thresholds.
ZodiacSign siderealSignFor(double lambda, int year) {
  final shifted =
      (lambda - kPrecessionDegPerYear * (year - _activeEpochYear)) % 360;
  for (var i = 0; i < 12; i++) {
    final start = _activeStarts[i];
    final end = _activeStarts[(i + 1) % 12];
    final inBand = start < end
        ? shifted >= start && shifted < end
        : shifted >= start || shifted < end;
    if (inBand) return ZodiacSign.values[i];
  }
  // The twelve bands cover the full circle; shifted is always in [0, 360).
  throw StateError('no constellation band for longitude $shifted');
}

/// Element of [sign]: the fruit/root/flower/leaf cycle repeats three times
/// around the zodiac starting at Aries (spec §14.4).
BiodynamicElement elementOf(ZodiacSign sign) =>
    BiodynamicElement.values[sign.index % 4];
