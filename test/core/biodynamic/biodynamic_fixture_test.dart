import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';

/// T1.10 reference fixture: two full months of engine output (July + August
/// 2026), computed by the engine itself at creation (2026-07-31) and pinned
/// here to catch regression drift in the coefficients, zodiac boundaries or
/// unfavorable-window calibration.
///
/// Provenance (own computation, legally clean): anchors verified by hand at
/// creation against public almanac facts — new moon 2026-07-14 (illum 0.000),
/// full moon 2026-07-29 (illum 1.000), new moon 2026-08-12 = total solar
/// eclipse (unfavorable), full moon 2026-08-28 = partial lunar eclipse
/// (unfavorable) — plus a private cross-check of every layer against the
/// tmp/ prototype (not in the repo).
///
/// Transition times are local wall-clock CET/CEST: CI pins TZ
/// Europe/Ljubljana for the test step (ci.yml), do not remove.
///
/// Row: date, sidereal sign + transition, tropical sign + transition, then
/// the system-independent layers (phase, illuminated fraction, ascending,
/// unfavorable).
typedef _Row = (
  String,
  ZodiacSign,
  String?,
  ZodiacSign,
  String?,
  MoonPhase,
  double,
  bool,
  bool,
);

const List<_Row> _rows = [
  ('2026-07-01', ZodiacSign.sagittarius, '20:01', ZodiacSign.capricorn, '21:34', MoonPhase.fullMoon, 0.982, true, false),
  ('2026-07-02', ZodiacSign.capricorn, null, ZodiacSign.aquarius, null, MoonPhase.waningGibbous, 0.947, true, false),
  ('2026-07-03', ZodiacSign.capricorn, null, ZodiacSign.aquarius, null, MoonPhase.waningGibbous, 0.894, true, false),
  ('2026-07-04', ZodiacSign.capricorn, '02:57', ZodiacSign.aquarius, '08:31', MoonPhase.waningGibbous, 0.826, true, true),
  ('2026-07-05', ZodiacSign.aquarius, null, ZodiacSign.pisces, null, MoonPhase.waningGibbous, 0.743, true, false),
  ('2026-07-06', ZodiacSign.aquarius, '02:34', ZodiacSign.pisces, '17:08', MoonPhase.lastQuarter, 0.648, true, false),
  ('2026-07-07', ZodiacSign.pisces, null, ZodiacSign.aries, null, MoonPhase.lastQuarter, 0.543, true, false),
  ('2026-07-08', ZodiacSign.pisces, '22:14', ZodiacSign.aries, '22:32', MoonPhase.lastQuarter, 0.434, true, false),
  ('2026-07-09', ZodiacSign.aries, null, ZodiacSign.taurus, null, MoonPhase.lastQuarter, 0.324, true, false),
  ('2026-07-10', ZodiacSign.aries, '15:06', ZodiacSign.taurus, null, MoonPhase.waningCrescent, 0.220, true, false),
  ('2026-07-11', ZodiacSign.taurus, null, ZodiacSign.taurus, '00:42', MoonPhase.waningCrescent, 0.129, true, false),
  ('2026-07-12', ZodiacSign.taurus, null, ZodiacSign.gemini, null, MoonPhase.waningCrescent, 0.059, true, true),
  ('2026-07-13', ZodiacSign.taurus, '01:00', ZodiacSign.gemini, '00:48', MoonPhase.newMoon, 0.015, false, true),
  ('2026-07-14', ZodiacSign.gemini, '21:36', ZodiacSign.cancer, null, MoonPhase.newMoon, 0.000, false, false),
  ('2026-07-15', ZodiacSign.cancer, null, ZodiacSign.cancer, '00:37', MoonPhase.newMoon, 0.015, false, false),
  ('2026-07-16', ZodiacSign.cancer, '07:52', ZodiacSign.leo, null, MoonPhase.waxingCrescent, 0.057, false, true),
  ('2026-07-17', ZodiacSign.leo, null, ZodiacSign.leo, '02:08', MoonPhase.waxingCrescent, 0.122, false, true),
  ('2026-07-18', ZodiacSign.leo, '20:08', ZodiacSign.virgo, null, MoonPhase.waxingCrescent, 0.204, false, false),
  ('2026-07-19', ZodiacSign.virgo, null, ZodiacSign.virgo, '06:58', MoonPhase.waxingCrescent, 0.296, false, false),
  ('2026-07-20', ZodiacSign.virgo, null, ZodiacSign.libra, null, MoonPhase.firstQuarter, 0.395, false, false),
  ('2026-07-21', ZodiacSign.virgo, null, ZodiacSign.libra, '15:36', MoonPhase.firstQuarter, 0.495, false, false),
  ('2026-07-22', ZodiacSign.virgo, '11:15', ZodiacSign.scorpio, null, MoonPhase.firstQuarter, 0.593, false, false),
  ('2026-07-23', ZodiacSign.libra, '23:22', ZodiacSign.scorpio, null, MoonPhase.firstQuarter, 0.686, false, false),
  ('2026-07-24', ZodiacSign.scorpio, null, ZodiacSign.scorpio, '03:08', MoonPhase.waxingGibbous, 0.771, false, false),
  ('2026-07-25', ZodiacSign.scorpio, null, ZodiacSign.sagittarius, null, MoonPhase.waxingGibbous, 0.846, false, false),
  ('2026-07-26', ZodiacSign.scorpio, '14:00', ZodiacSign.sagittarius, '15:46', MoonPhase.waxingGibbous, 0.908, true, false),
  ('2026-07-27', ZodiacSign.sagittarius, null, ZodiacSign.capricorn, null, MoonPhase.waxingGibbous, 0.955, true, false),
  ('2026-07-28', ZodiacSign.sagittarius, null, ZodiacSign.capricorn, null, MoonPhase.fullMoon, 0.987, true, false),
  ('2026-07-29', ZodiacSign.sagittarius, '02:16', ZodiacSign.capricorn, '03:47', MoonPhase.fullMoon, 1.000, true, false),
  ('2026-07-30', ZodiacSign.capricorn, null, ZodiacSign.aquarius, null, MoonPhase.fullMoon, 0.994, true, false),
  ('2026-07-31', ZodiacSign.capricorn, '08:44', ZodiacSign.aquarius, '14:15', MoonPhase.fullMoon, 0.968, true, true),
  ('2026-08-01', ZodiacSign.aquarius, null, ZodiacSign.pisces, null, MoonPhase.waningGibbous, 0.923, true, false),
  ('2026-08-02', ZodiacSign.aquarius, '08:04', ZodiacSign.pisces, '22:38', MoonPhase.waningGibbous, 0.859, true, false),
  ('2026-08-03', ZodiacSign.pisces, null, ZodiacSign.aries, null, MoonPhase.waningGibbous, 0.778, true, false),
  ('2026-08-04', ZodiacSign.pisces, null, ZodiacSign.aries, null, MoonPhase.lastQuarter, 0.683, true, false),
  ('2026-08-05', ZodiacSign.pisces, '04:18', ZodiacSign.aries, '04:37', MoonPhase.lastQuarter, 0.577, true, false),
  ('2026-08-06', ZodiacSign.aries, '22:14', ZodiacSign.taurus, null, MoonPhase.lastQuarter, 0.464, true, false),
  ('2026-08-07', ZodiacSign.taurus, null, ZodiacSign.taurus, '08:08', MoonPhase.lastQuarter, 0.351, true, false),
  ('2026-08-08', ZodiacSign.taurus, null, ZodiacSign.gemini, null, MoonPhase.waningCrescent, 0.244, true, false),
  ('2026-08-09', ZodiacSign.taurus, '09:59', ZodiacSign.gemini, '09:47', MoonPhase.waningCrescent, 0.150, false, false),
  ('2026-08-10', ZodiacSign.gemini, null, ZodiacSign.cancer, null, MoonPhase.waningCrescent, 0.075, false, true),
  ('2026-08-11', ZodiacSign.gemini, '07:36', ZodiacSign.cancer, '10:39', MoonPhase.newMoon, 0.024, false, true),
  ('2026-08-12', ZodiacSign.cancer, '18:08', ZodiacSign.leo, null, MoonPhase.newMoon, 0.001, false, true),
  ('2026-08-13', ZodiacSign.leo, null, ZodiacSign.leo, '12:19', MoonPhase.newMoon, 0.006, false, true),
  ('2026-08-14', ZodiacSign.leo, null, ZodiacSign.virgo, null, MoonPhase.newMoon, 0.037, false, false),
  ('2026-08-15', ZodiacSign.leo, '05:44', ZodiacSign.virgo, '16:21', MoonPhase.waxingCrescent, 0.090, false, false),
  ('2026-08-16', ZodiacSign.virgo, null, ZodiacSign.libra, null, MoonPhase.waxingCrescent, 0.161, false, false),
  ('2026-08-17', ZodiacSign.virgo, null, ZodiacSign.libra, '23:47', MoonPhase.waxingCrescent, 0.244, false, false),
  ('2026-08-18', ZodiacSign.virgo, '19:06', ZodiacSign.scorpio, null, MoonPhase.firstQuarter, 0.336, false, false),
  ('2026-08-19', ZodiacSign.libra, null, ZodiacSign.scorpio, null, MoonPhase.firstQuarter, 0.432, false, false),
  ('2026-08-20', ZodiacSign.libra, '06:47', ZodiacSign.scorpio, '10:31', MoonPhase.firstQuarter, 0.529, false, false),
  ('2026-08-21', ZodiacSign.scorpio, null, ZodiacSign.sagittarius, null, MoonPhase.firstQuarter, 0.623, false, false),
  ('2026-08-22', ZodiacSign.scorpio, '21:15', ZodiacSign.sagittarius, '23:00', MoonPhase.waxingGibbous, 0.713, false, false),
  ('2026-08-23', ZodiacSign.sagittarius, null, ZodiacSign.capricorn, null, MoonPhase.waxingGibbous, 0.795, true, false),
  ('2026-08-24', ZodiacSign.sagittarius, null, ZodiacSign.capricorn, null, MoonPhase.waxingGibbous, 0.866, true, false),
  ('2026-08-25', ZodiacSign.sagittarius, '09:32', ZodiacSign.capricorn, '11:03', MoonPhase.waxingGibbous, 0.925, true, false),
  ('2026-08-26', ZodiacSign.capricorn, null, ZodiacSign.aquarius, null, MoonPhase.fullMoon, 0.968, true, false),
  ('2026-08-27', ZodiacSign.capricorn, '15:38', ZodiacSign.aquarius, '21:05', MoonPhase.fullMoon, 0.994, true, true),
  ('2026-08-28', ZodiacSign.aquarius, null, ZodiacSign.pisces, null, MoonPhase.fullMoon, 0.999, true, true),
  ('2026-08-29', ZodiacSign.aquarius, '14:18', ZodiacSign.pisces, null, MoonPhase.fullMoon, 0.983, true, false),
  ('2026-08-30', ZodiacSign.pisces, null, ZodiacSign.pisces, '04:39', MoonPhase.waningGibbous, 0.946, true, false),
  ('2026-08-31', ZodiacSign.pisces, null, ZodiacSign.aries, null, MoonPhase.waningGibbous, 0.886, true, false),
];

String? _hm(DateTime? t) => t == null
    ? null
    : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

void main() {
  test('fixture covers July and August 2026 without gaps', () {
    expect(_rows, hasLength(62));
    expect(_rows.first.$1, '2026-07-01');
    expect(_rows.last.$1, '2026-08-31');
  });

  group('engine matches the pinned July/August 2026 reference', () {
    for (final row in _rows) {
      final (date, sidSign, sidAt, tropSign, tropAt, phase, illum, asc, unfav) =
          row;
      test(date, () {
        final parts = date.split('-').map(int.parse).toList();
        final day = DateTime(parts[0], parts[1], parts[2]);
        final sid = dayFor(day, CalendarSystem.sidereal);
        final trop = dayFor(day, CalendarSystem.tropical);

        expect(sid.sign, sidSign);
        expect(_hm(sid.transitionAt), sidAt);
        expect(trop.sign, tropSign);
        expect(_hm(trop.transitionAt), tropAt);

        for (final d in [sid, trop]) {
          expect(d.phase, phase);
          expect(d.illumFraction, closeTo(illum, 0.0006));
          expect(d.ascending, asc);
          expect(d.unfavorable, unfav);
        }
      });
    }
  });
}
