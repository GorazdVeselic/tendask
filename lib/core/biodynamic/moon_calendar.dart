import 'biodynamic_day.dart';
import 'calendar_system.dart';

/// Computes the biodynamic layers for one local calendar day (FR-19 spec §14).
///
/// Time contract: [localDate] is a local calendar day (`DateTime(y, m, d)` in
/// the caller's zone); the day spans local midnight to midnight. All astronomy
/// runs internally in UTC. Pure function: no I/O, no clock, no state.
BiodynamicDay dayFor(DateTime localDate, CalendarSystem system) {
  // TODO(gorazd, 2026-08-15): implemented incrementally in T1.2..T1.9.
  throw UnimplementedError('Biodynamic engine not implemented yet (T1.2+).');
}
