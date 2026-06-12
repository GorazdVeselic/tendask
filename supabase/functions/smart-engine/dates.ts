// Date helpers. All "day" values are YYYY-MM-DD strings (lexically comparable);
// conversion UTC → user-local day goes through IANA timezone via Intl.

const dtfCache = new Map<string, Intl.DateTimeFormat>();

export function safeTimeZone(tz: string | null | undefined): string {
  if (!tz) return 'UTC';
  try {
    new Intl.DateTimeFormat('en-CA', { timeZone: tz });
    return tz;
  } catch {
    return 'UTC';
  }
}

/** Local calendar day (YYYY-MM-DD) of a UTC instant in the given timezone. */
export function localDateStr(utc: Date, timeZone: string): string {
  let dtf = dtfCache.get(timeZone);
  if (!dtf) {
    // en-CA formats as YYYY-MM-DD directly.
    dtf = new Intl.DateTimeFormat('en-CA', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    });
    dtfCache.set(timeZone, dtf);
  }
  return dtf.format(utc);
}

const kDayMs = 86_400_000;

function dayMs(day: string): number {
  return Date.parse(day + 'T00:00:00Z');
}

function msToDay(ms: number): string {
  return new Date(ms).toISOString().slice(0, 10);
}

export function addDaysStr(day: string, n: number): string {
  return msToDay(dayMs(day) + n * kDayMs);
}

/** Calendar day of a UTC instant at a fixed UTC offset (fallback when no IANA
 * timezone is available — e.g. cell offset from the weather payload). */
export function offsetDateStr(utc: Date, offsetSeconds: number): string {
  return msToDay(utc.getTime() + offsetSeconds * 1000);
}

/** Whole days a − b (positive when a is later). */
export function dayDiff(a: string, b: string): number {
  return Math.round((dayMs(a) - dayMs(b)) / kDayMs);
}

/** DOY (1-based) → date in the given year. DOY uses the non-leap convention
 * (docs/m11/07 §7.3); the ±1 day drift in leap years is below noise. */
export function doyToDateStr(year: number, doy: number): string {
  return msToDay(Date.UTC(year, 0, doy));
}

/** Same calendar date one year earlier (Feb 29 normalises to Mar 1). */
export function sameDateLastYear(day: string): string {
  const y = Number(day.slice(0, 4));
  const m = Number(day.slice(5, 7));
  const d = Number(day.slice(8, 10));
  return msToDay(Date.UTC(y - 1, m - 1, d));
}

export function isoWeek(day: string): number {
  const date = new Date(dayMs(day));
  const weekday = (date.getUTCDay() + 6) % 7; // Mon = 0
  date.setUTCDate(date.getUTCDate() - weekday + 3); // Thursday of this ISO week
  const firstThursday = new Date(Date.UTC(date.getUTCFullYear(), 0, 4));
  const firstWeekday = (firstThursday.getUTCDay() + 6) % 7;
  firstThursday.setUTCDate(firstThursday.getUTCDate() - firstWeekday + 3);
  return 1 + Math.round((date.getTime() - firstThursday.getTime()) / (7 * kDayMs));
}
