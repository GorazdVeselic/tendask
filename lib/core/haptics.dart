import 'dart:async';

import 'package:flutter/services.dart';

/// Short tactile confirmation for key user actions, so a tap registers even
/// when used outdoors (gloves, sun on the screen). One place owns the
/// intensity mapping; a future settings toggle would gate it here.
///
/// OS-disabled vibration makes these no-ops, so they are safe to call
/// unconditionally; the platform channel call is fire-and-forget.
abstract final class AppHaptics {
  /// A task was marked done — the most frequent action.
  static void taskCompleted() => unawaited(HapticFeedback.lightImpact());

  /// A form / entry was saved.
  static void saved() => unawaited(HapticFeedback.mediumImpact());

  /// A destructive action (delete, sign-out) was confirmed — strongest signal.
  static void destructiveConfirmed() => unawaited(HapticFeedback.heavyImpact());
}
