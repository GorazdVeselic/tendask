import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';

/// T1.11 micro-benchmark: a month view is 42 cells (6 weeks x 7 days) and the
/// UI may want both systems, so one grid = 84 dayFor calls. Measured on the
/// dev machine (2026-07-31, JIT test VM): ~16 ms per grid, ~0.19 ms per call
/// — above the "few ms" target, so per the plan the T3 provider memoizes on
/// (month, system); the engine itself stays memoization-free. The assertion
/// bound is deliberately loose so slow CI runners do not flake; the measured
/// value is printed for the log.
void main() {
  test('dayFor month grid (42 cells x 2 systems) stays in the ms range', () {
    List<Object> grid(DateTime firstCell) => [
          for (var i = 0; i < 42; i++)
            for (final system in CalendarSystem.values)
              dayFor(
                DateTime(firstCell.year, firstCell.month, firstCell.day + i),
                system,
              ),
        ];

    // Warmup so JIT compilation does not count toward the measurement.
    for (var i = 0; i < 3; i++) {
      grid(DateTime(2026, 6, 29));
    }

    const iterations = 10;
    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      grid(DateTime(2026, 6, 29));
    }
    stopwatch.stop();

    final perGridMs =
        stopwatch.elapsedMicroseconds / 1000 / iterations;
    debugPrint(
      'dayFor month grid (84 calls): ${perGridMs.toStringAsFixed(2)} ms',
    );
    expect(perGridMs, lessThan(100));
  });
}
