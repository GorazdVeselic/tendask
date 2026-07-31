import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';

void main() {
  group('dayFor unfavorable layer', () {
    test('all four 2024 eclipse days are unfavorable', () {
      final eclipseDays = [
        DateTime(2024, 3, 25), // penumbral lunar
        DateTime(2024, 4, 8), // total solar
        DateTime(2024, 9, 18), // partial lunar
        DateTime(2024, 10, 2), // annular solar
      ];
      for (final date in eclipseDays) {
        final day = dayFor(date, CalendarSystem.sidereal);
        expect(day.unfavorable, isTrue, reason: '$date');
      }
    });

    test('is system-independent (pure astronomy, spec layer table)', () {
      for (var offset = 0; offset < 60; offset++) {
        final date = DateTime(2026, 3, 1 + offset);
        expect(
          dayFor(date, CalendarSystem.sidereal).unfavorable,
          dayFor(date, CalendarSystem.tropical).unfavorable,
          reason: '$date',
        );
      }
    });

    test('matches the printed Thun 2024 node/perigee marks (jan/feb/dec)', () {
      // Printed reference (photographed jan/feb/dec pages): every day whose
      // node/perigee window overlaps it. Days 1.2., 10.12., 13.12. and 23.12.
      // are sub-5-hour midnight tails of a real event; the print shows the
      // analogous tails on 14.1. (1 h) and 28.2. (4 h) but drops these, so
      // the model keeps them (conservative). Printed marks driven by
      // planetary events (Mercury/Venus nodes, conjunctions) are excluded
      // by design (spec §4.5) and stay unflagged.
      final expected = {
        1: [4, 12, 13, 14, 17, 31],
        2: [1, 10, 11, 13, 27, 28],
        12: [9, 10, 12, 13, 22, 23],
      };
      for (final MapEntry(key: month, value: days) in expected.entries) {
        final flagged = <int>[];
        for (var d = DateTime(2024, month, 1);
            d.month == month;
            d = DateTime(d.year, d.month, d.day + 1)) {
          if (dayFor(d, CalendarSystem.sidereal).unfavorable == true) {
            flagged.add(d.day);
          }
        }
        expect(flagged, days, reason: 'month $month');
      }
    });

    test('yearly count stays in the physical band', () {
      // ~27 node passages + ~13 perigees per year, each window marking one
      // or two days, minus overlaps: a broad sanity band, not a calibration.
      var count = 0;
      for (var d = DateTime(2026, 1, 1);
          d.year == 2026;
          d = DateTime(d.year, d.month, d.day + 1)) {
        final day = dayFor(d, CalendarSystem.sidereal);
        expect(day.unfavorable, isNotNull, reason: '$d');
        if (day.unfavorable == true) count++;
      }
      expect(count, inInclusiveRange(30, 100));
    });
  });
}
