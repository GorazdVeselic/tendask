// Centralised error sink for the smart engine. Supabase forwards console.* to
// the platform log drain, so one structured line per failure keeps engine
// errors queryable (filter evt="engine_error", group by stage) and is the
// single seam to wire an external reporter (Sentry DSN via env) later without
// touching call sites.

function describe(err: unknown): Record<string, unknown> {
  if (err instanceof Error) return { message: err.message, stack: err.stack };
  if (err && typeof err === 'object') return { detail: err };
  return { message: String(err) };
}

/** Report a non-fatal engine error. `stage` names the failing step. */
export function reportError(
  stage: string,
  err: unknown,
  ctx?: Record<string, unknown>,
): void {
  console.error(JSON.stringify({ evt: 'engine_error', stage, ...ctx, ...describe(err) }));
  // Seam: if (Deno.env.get('SENTRY_DSN')) void sendToSentry(...) — deferred (no DSN yet).
}
