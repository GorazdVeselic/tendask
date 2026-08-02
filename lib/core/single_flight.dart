import 'dart:async';

/// Serializes an idempotent background job that several triggers may ask for at
/// once — the notification coordinators (reminders, journal nudge, moon hint)
/// all re-run the same "cancel everything, schedule what is due" pass.
///
/// Two guarantees:
///  * only one run at a time; a request that arrives mid-run does not queue up
///    N runs, it marks the current one stale and re-runs exactly once after it;
///  * [runSoon] collapses a burst of triggers (rapid drift writes) into one run.
///
/// The job owns its own error handling: a throw is not swallowed here, it
/// propagates to the caller's `unawaited` (the coordinators wrap the body in
/// their own try/catch with their own log message).
class SingleFlight {
  SingleFlight(this._job);

  final Future<void> Function() _job;

  Timer? _debounce;
  bool _running = false;
  bool _dirty = false;

  /// True while a run is in flight (diagnostics and tests).
  bool get isRunning => _running;

  /// Runs the job now, or marks the in-flight run stale so it repeats once.
  Future<void> run() async {
    if (_running) {
      _dirty = true;
      return;
    }
    _running = true;
    try {
      await _job();
    } finally {
      _running = false;
      if (_dirty) {
        _dirty = false;
        unawaited(run());
      }
    }
  }

  /// Runs the job after [delay], restarting the wait on every call so a burst
  /// of triggers costs one run.
  void runSoon(Duration delay) {
    _debounce?.cancel();
    _debounce = Timer(delay, () => unawaited(run()));
  }

  /// Cancels a pending [runSoon]. Call from the owner's dispose.
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
  }
}
