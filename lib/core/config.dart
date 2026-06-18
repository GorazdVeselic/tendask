/// App-wide tunable constants (CLAUDE.md §"Konstante in konfiguracija").
library;

/// Default garden location for the weather snapshot until the user sets one;
/// once set, weather uses the on-device H3 r7 cell centroid (FR-8). Privacy:
/// real coordinates are never stored; this is a fixed fallback, overridable via
/// --dart-define for testing other regions. Default = Ljubljana. (Dart has no
/// `double.fromEnvironment`, so coordinates come in as strings.)
const _latEnv = String.fromEnvironment('WEATHER_LAT');
const _lonEnv = String.fromEnvironment('WEATHER_LON');
final kDefaultLatitude = _latEnv.isEmpty ? 46.0569 : double.parse(_latEnv);
final kDefaultLongitude = _lonEnv.isEmpty ? 14.5058 : double.parse(_lonEnv);

/// Open-Meteo is retried at most 3 times (one initial attempt + these waits),
/// with exponential backoff, before giving up gracefully (offline = null).
const kWeatherRetryDelays = <Duration>[
  Duration(seconds: 1),
  Duration(seconds: 3),
];

/// How long a fetched dashboard weather snapshot stays fresh before a re-fetch.
/// Avoids a network call on every visit to Home (weather changes slowly).
const kWeatherCacheTtl = Duration(minutes: 30);

/// How long a persisted snapshot may still be shown when a re-fetch fails
/// (offline or a degraded Open-Meteo). Generous on purpose: opening the app the
/// next morning must show yesterday's weather (with a "updated at" stamp) rather
/// than a blank card. Past this the dashboard degrades to "unavailable", because
/// the forecast strip would then be mostly past days. Survives app restarts.
const kWeatherStaleTtl = Duration(hours: 48);

/// Task types shown before the "show all" toggle on entry step 1 (3 rows × 3).
/// The rest stay collapsed until expanded; sorted by per-user frequency.
const kTaskTypeGridCollapsed = 9;

/// Max species shown in the "Frequent" row of the plant-add screen — the
/// most recently used catalog species, so common picks stay one tap away.
const kRecentPlantsLimit = 8;

/// Open-Meteo network timeouts. Receive is generous: the forecast payload
/// (hourly bands for ~5 days) is sizable and decodes slower in debug (non-AOT),
/// and 10 s proved too tight on slow mobile networks (gardens).
const kWeatherConnectTimeout = Duration(seconds: 10);
const kWeatherReceiveTimeout = Duration(seconds: 20);

/// Periodic background sync cadence while the app is running. Sync is
/// incremental and light; the catalog (rarely changes) is pulled only on
/// startup/reconnect, not on every tick — keeps the garden device's data and
/// battery use down (CLAUDE.md §efficiency).
const kSyncInterval = Duration(minutes: 15);

/// Debounce window for push-on-save: a write to a synced table schedules a push
/// after this delay, batching rapid edits so a change reaches the cloud within
/// seconds (not on the next [kSyncInterval] tick) without a push per keystroke.
const kPushDebounce = Duration(seconds: 2);

/// Debounce window for reminder reconcile: a write to task/task_reminder
/// reschedules OS notifications after this delay, coalescing rapid edits.
const kReminderDebounce = Duration(milliseconds: 800);

/// Default reminder offset (minutes before the task) prefilled when adding a new
/// reminder. 1440 = one day before. User-overridable in notification settings.
const kDefaultReminderOffset = 1440;

/// Quiet-hours window shown in notification settings (display only in MVP). It
/// is stored as a device-local preference and governs the future weather/
/// community hints (FCM, deferred), NOT explicit task reminders — see
/// koncept.md §"Vodenje proti motečnosti".
const kQuietHoursStartHour = 22;
const kQuietHoursEndHour = 7;

/// Supabase cloud backend (M5). URL + publishable key arrive ONLY via
/// --dart-define (never committed — see dart_defines.json, gitignored). When
/// empty the app stays fully offline (drift is the source of truth), so the
/// bootstrap skips Supabase init instead of crashing.
const kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const kSupabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

/// Human-readable backend environment, derived from [kSupabaseUrl] and logged
/// once at boot so a debug session can never silently target the wrong backend.
/// Staging URLs carry the `staging` host segment; everything else is production
/// (and an empty URL means fully offline).
String get kEnvLabel {
  if (kSupabaseUrl.isEmpty) return 'offline (no backend)';
  return kSupabaseUrl.contains('staging') ? 'staging' : 'production';
}

/// Google OAuth **Web** client id (serverClientId for native Google sign-in,
/// M7.4). Arrives via --dart-define (see dart_defines.json). Empty → the Google
/// button stays disabled (the rest of the app, incl. email sign-in, still works).
const kGoogleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Minimum time the branded splash (zaslon 00) stays visible before routing on,
/// so the logo + wordmark + version are readable on a fast cold start.
const kSplashMinDuration = Duration(milliseconds: 1200);

/// Release-channel suffix appended to the displayed version (e.g. " (beta)" for
/// the internal/beta track). Empty for a production release — one place to flip.
const kVersionChannel = ' (beta)';

/// Supplies feature gate (temporarily off): hides the supplies wizard step and
/// the settings garden/supplies section without removing the code. Flip to true
/// to re-enable. See entry_screen (step list) and settings_screen.
const kSuppliesEnabled = false;

/// Sentry crash/error monitoring DSN (M9.1). Arrives ONLY via --dart-define
/// (never committed — see dart_defines.json, gitignored). Empty → Sentry stays
/// off and the app runs normally (same offline-first pattern as Supabase).
const kSentryDsn = String.fromEnvironment('SENTRY_DSN');

/// Public privacy policy (GDPR). Shown as a tappable link on the sign-in screen
/// and in Settings; same URL is submitted to Play Console.
const kPrivacyPolicyUrl = 'https://tendask.netlify.app/';

/// Minimum gap between OTP code sends (FR-11). Mirrors Supabase's server-side
/// ~60 s throttle so the resend button counts down locally instead of letting
/// the user hit a server error. UX rate-limit only; the hard cap stays server-side.
const kOtpResendCooldown = Duration(seconds: 60);

/// Timeout for the DNS-over-HTTPS domain-existence check (FR-11). Deliberately
/// short: it runs before sending the OTP, and a slow/failed lookup must fail
/// OPEN (proceed) rather than make sign-in feel stuck — only a definitive
/// "domain does not exist" blocks.
const kDnsCheckTimeout = Duration(seconds: 3);
