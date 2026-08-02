/// Plant part favoured by the day, mapped from the classical element
/// (fire, earth, air, water) of the Moon's zodiac position (FR-19 spec §14.4).
enum BiodynamicElement { fruit, root, flower, leaf }

/// The twelve zodiac divisions, in ecliptic order from 0 degrees.
///
/// Ophiuchus is not a standalone entry: its ecliptic band is absorbed into
/// the calibrated Scorpio -> Sagittarius boundary (boundaries doc §1).
enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

/// Eight-step lunar phase, bucketed from elongation (FR-19 spec §14.6).
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

/// Whether the Moon is filling towards full. The new moon counts as waxing:
/// display texts speak of the half of the cycle a day belongs to, and the
/// exact instant already carries its own marker.
/// Exhaustive on purpose: a new phase value must be classified here, not
/// silently fall to the waning half.
bool isWaxing(MoonPhase phase) => switch (phase) {
  MoonPhase.newMoon ||
  MoonPhase.waxingCrescent ||
  MoonPhase.firstQuarter ||
  MoonPhase.waxingGibbous => true,
  MoonPhase.fullMoon ||
  MoonPhase.waningGibbous ||
  MoonPhase.lastQuarter ||
  MoonPhase.waningCrescent => false,
};

/// Biodynamic layers of one local calendar day (FR-19 spec §14.8).
class BiodynamicDay {
  const BiodynamicDay({
    required this.sign,
    required this.isConstellation,
    required this.element,
    this.transitionAt,
    this.secondaryElement,
    required this.phase,
    required this.illumFraction,
    this.ascending,
    this.unfavorable,
  })  : assert(
          (transitionAt == null) == (secondaryElement == null),
          'transitionAt and secondaryElement must be set together',
        ),
        assert(illumFraction >= 0 && illumFraction <= 1);

  /// Zodiac division at the start of the day (day label convention, spec §12.6).
  final ZodiacSign sign;

  /// True when [sign] is a sidereal constellation, false for a tropical sign.
  final bool isConstellation;

  /// Element at the start of the day.
  final BiodynamicElement element;

  /// Local wall-clock time of the element change within the day, if any.
  final DateTime? transitionAt;

  /// Element after [transitionAt]; null when the day has no transition.
  final BiodynamicElement? secondaryElement;

  /// Lunar phase (system-independent).
  final MoonPhase phase;

  /// Illuminated fraction of the Moon's disc, 0 (new) .. 1 (full).
  final double illumFraction;

  /// True while the Moon's declination is increasing (ascending Moon).
  final bool? ascending;

  /// True on unfavorable days (lunar node, eclipse, perigee).
  final bool? unfavorable;
}
