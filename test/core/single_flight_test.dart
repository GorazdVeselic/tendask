import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/single_flight.dart';

/// The re-entrancy guard the three notification coordinators share (reminders,
/// journal nudge, moon hint). It used to be copied into each of them, where the
/// feature flag or a database made it untestable.
void main() {
  test('a request during a run re-runs the job exactly once', () async {
    var runs = 0;
    final gate = Completer<void>();
    late final SingleFlight flight;
    flight = SingleFlight(() async {
      runs++;
      if (runs == 1) await gate.future;
    });

    final first = flight.run();
    // Three triggers land while the first run is still in flight.
    await flight.run();
    await flight.run();
    await flight.run();
    expect(runs, 1, reason: 'nothing may start while one is running');

    gate.complete();
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(runs, 2, reason: 'the burst collapses into one repeat, not three');
    expect(flight.isRunning, isFalse);
  });

  test('a throwing job still clears the guard', () async {
    var runs = 0;
    final flight = SingleFlight(() async {
      runs++;
      throw StateError('boom');
    });

    await expectLater(flight.run(), throwsStateError);
    expect(flight.isRunning, isFalse);

    // The next trigger must not be swallowed by a stuck _running flag.
    await expectLater(flight.run(), throwsStateError);
    expect(runs, 2);
  });

  test('runSoon collapses a burst into one delayed run', () async {
    var runs = 0;
    final flight = SingleFlight(() async => runs++);
    const delay = Duration(milliseconds: 40);

    flight.runSoon(delay);
    await Future<void>.delayed(const Duration(milliseconds: 25));
    flight.runSoon(delay); // restarts the wait
    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(runs, 0, reason: 'the second call restarted the wait');

    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(runs, 1, reason: 'a burst costs exactly one run');
  });

  test('dispose cancels a pending run', () async {
    var runs = 0;
    final flight = SingleFlight(() async => runs++);

    flight.runSoon(const Duration(milliseconds: 40));
    flight.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(runs, 0);
  });
}
