/// App-wide tunable constants (CLAUDE.md §"Konstante in konfiguracija").
library;

/// Default garden location used for the weather snapshot until M7 wires the
/// on-device H3 cell centroid as the source. Privacy: real coordinates are
/// never stored; this is a fixed fallback, overridable via --dart-define for
/// testing other regions. Default = Ljubljana. (Dart has no
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

/// Task types shown before the "show all" toggle on entry step 1 (3 rows × 3).
/// The rest stay collapsed until expanded; sorted by per-user frequency.
const kTaskTypeGridCollapsed = 9;

/// Open-Meteo network timeouts. Receive is generous: the forecast payload
/// (hourly bands for ~5 days) is sizable and decodes slower in debug (non-AOT),
/// and 10 s proved too tight on slow mobile networks (gardens).
const kWeatherConnectTimeout = Duration(seconds: 10);
const kWeatherReceiveTimeout = Duration(seconds: 20);
