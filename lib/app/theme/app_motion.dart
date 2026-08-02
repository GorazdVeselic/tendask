/// Animation durations, in one place (CLAUDE.md: no magic values in widgets).
///
/// Four steps, so motion across the app feels like one system instead of a
/// dozen hand-picked numbers. Pick by role, not by milliseconds.
library;

/// Small state flips a finger is waiting on (selection, chip, tile).
const kMotionFast = Duration(milliseconds: 150);

/// Ordinary transitions: banners expanding, toasts, step changes.
const kMotionMedium = Duration(milliseconds: 220);

/// Larger moves that need to read as one gesture (page/step slide, card flip).
const kMotionSlow = Duration(milliseconds: 300);

/// The splash breath — deliberately its own, and far longer than any UI move.
const kMotionSplashPulse = Duration(milliseconds: 1000);

/// How long a top toast stays before it fades out on its own — a dwell, not a
/// motion, so it keeps its own value.
const kToastVisible = Duration(milliseconds: 2200);
