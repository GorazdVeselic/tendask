/// Every emoji glyph the UI draws, in one place.
///
/// Emoji instead of custom vectors is decision A5 (FR-19) and the pattern the
/// wireframes use throughout. A surface never inlines a glyph literal: two
/// screens showing "the same thing" must not be able to drift apart, and a
/// swap is then one edit here. Domain mappings (element, area type) stay next
/// to their domain — they map onto these constants.
library;

// ── Biodynamic elements (FR-19) ─────────────────────────────────────────────
const kGlyphFruit = '🍅';
const kGlyphRoot = '🥕';
const kGlyphFlower = '🌸';
const kGlyphLeaf = '🌿';

// ── Area types ──────────────────────────────────────────────────────────────
const kGlyphAreaGarden = '🌻';
const kGlyphAreaLawn = '🌱';
const kGlyphAreaHedge = '🌿';
const kGlyphAreaBed = '🪴';
const kGlyphAreaTree = '🍎';
const kGlyphAreaOrnamental = '🌸';
const kGlyphAreaOther = '📍';

// ── Fallbacks for catalog rows without an icon ──────────────────────────────
/// Plant with no catalog icon (and private entries).
const kGlyphPlantFallback = '🌿';

/// Task type with no catalog icon.
const kGlyphTaskTypeFallback = '📋';

// ── Recurring UI glyphs ─────────────────────────────────────────────────────
/// Prefix of a task/note subject line ("🪴 tomato").
const kGlyphSubject = '🪴';

/// Journal note entry.
const kGlyphNote = '✍️';

/// Seedling — empty garden, "garden" notification group.
const kGlyphSeedling = '🌱';

/// Privacy note ("stays on your device").
const kGlyphPrivacy = '🔒';

/// Notification / reminder.
const kGlyphBell = '🔔';

/// Weather-driven notification.
const kGlyphWeather = '🌤️';

/// Nearby-gardeners notification.
const kGlyphNearby = '🌍';

/// Preview row (see what a notification looks like).
const kGlyphPreview = '👁';

// ── Moon calendar (FR-19) ───────────────────────────────────────────────────
/// The moon calendar itself (settings switch, "what is this" card).
const kGlyphMoon = '🌙';

/// Astro details (constellation / phase block and its sub-toggle).
const kGlyphAstro = '🌌';

/// Calendar layer in the journal.
const kGlyphCalendarLayer = '📅';

/// Element labels on tasks and plants (their sub-toggle).
const kGlyphElementLabels = '🏷️';

/// Day the user's own garden can use.
const kGlyphStar = '★';

/// Ascending / descending moon.
const kGlyphAscending = '↗';
const kGlyphDescending = '↘';

// ── Tendask+ (FR-20) ────────────────────────────────────────────────────────
/// Harvest analytics (a future Tendask+ feature).
const kGlyphAnalytics = '📊';

// ── Supplies ────────────────────────────────────────────────────────────────
const kGlyphSupplyFertilizer = '🧪';
const kGlyphSupplyTreatment = '🧴';
const kGlyphSupplyEquipment = '🛢️';
const kGlyphSupplyOther = '📦';

/// A recipe (a named mix of supplies).
const kGlyphRecipe = '📋';

/// Stock that has fallen under its low-stock threshold.
const kGlyphLowStock = '⚠️';

// ── Tasks ───────────────────────────────────────────────────────────────────
/// Harvest yield.
const kGlyphHarvest = '🧺';

/// Task-detail state badges: waiting (dated) and done.
const kGlyphWaiting = '📅';
const kGlyphDone = '✓';

/// Subject that is an area rather than a plant.
const kGlyphAreaFallback = '🪴';

/// Inline hint ("tip: …").
const kGlyphHint = '💡';

/// Edit action.
const kGlyphEdit = '✏️';

// ── Settings rows ───────────────────────────────────────────────────────────
const kGlyphLocation = '📍';
const kGlyphAppearance = '🎨';

// ── Weather conditions (Open-Meteo code buckets) ────────────────────────────
const kGlyphWeatherClear = '☀️';
const kGlyphWeatherMainlyClear = '🌤️';
const kGlyphWeatherCloudy = '☁️';
const kGlyphWeatherFog = '🌫️';
const kGlyphWeatherDrizzle = '🌦️';
const kGlyphWeatherRain = '🌧️';
const kGlyphWeatherSnow = '🌨️';
const kGlyphWeatherShowers = '🌦️';
const kGlyphWeatherThunderstorm = '⛈️';
const kGlyphWeatherUnknown = '🌡️';

/// "No weather to show" (no garden location, no frozen snapshot).
const kGlyphWeatherNone = '🌦️';

// ── Weather metrics (card and detail sheet) ─────────────────────────────────
const kGlyphHumidity = '💧';
const kGlyphWind = '🌬';
const kGlyphRain = '🌧';
const kGlyphSoil = '🌱';
const kGlyphSun = '☀️';
