-- ============================================================
-- 0008_m11_grants.sql — table grants for the M11 engine tables + harden
-- k_privacy() search_path. Additive-only, idempotent (re-granting and
-- create-or-replace are no-ops). 0006 enabled RLS and created policies but
-- granted nothing; PostgREST needs BOTH — RLS gates rows, grants gate table
-- access (see 0002 §2b). Explicit grants keep the API deterministic instead of
-- relying on default privileges (the convention this project committed to).
-- ============================================================

-- Catalog: agronomy rules are public-read (client pulls via catalog sync);
-- only the service-role seed writes them.
grant select on plant_task_rule to anon, authenticated;

-- suggestion: client pulls and pushes status changes via upsert (insert+update).
-- No delete — the client soft-deletes (deleted = true via update), matching the
-- select/insert/update-only policies in 0006 (no delete policy on purpose).
grant select, insert, update on suggestion to authenticated;

-- suggestion_log: read-only mirror of engine guard state (server is the only
-- writer; client never pushes it).
grant select on suggestion_log to authenticated;

-- engine_run, weather_cache, app_config: server-only — no client grant on
-- purpose (the engine writes them with the service role, which bypasses grants).

-- ============================================================
-- Pin search_path on the security-definer helper to match delete_account()
-- (0004) and engine_dispatch() (0007); 0006 left it as 'public'. Schema-qualify
-- the read so an empty search_path resolves. The function exists on the live DB
-- already, so harden it now rather than waiting for its first caller (M11.16).
-- ============================================================
create or replace function k_privacy() returns int
language sql stable security definer set search_path = '' as
$$ select (value)::int from public.app_config where key = 'k_privacy' $$;
