-- Tendask — FR-analytics: creation/ingestion timestamps for analytics.
-- See docs/feature-requests/analytics.md (Tier 1).
--
-- Adds two timestamps to every user-owned entity:
--   created_at         — creation time. Device-owned (like updated_at); the server
--                        default now() is only a safety net for clients that do not
--                        yet send it. NEVER changes on update.
--   server_inserted_at — server ingestion time. Server-owned, set once on the row's
--                        first insert (default now()); the device never sends it.
--                        Immune to device clock skew — use for sync/active/churn.
--
-- Backfill: existing rows get updated_at as the best available estimate. The app
-- went live (closed test) ~1 day before this migration, so for current rows
-- updated_at ≈ creation time (most rows were never edited after creation). This is
-- strictly better than a single fixed "lowest known date".
--
-- Additive + idempotent (CLAUDE.md "Sync, čas in shema"): add-if-not-exists,
-- backfill, then NOT NULL + default in the SAME migration. NOT NULL is safe — old
-- APKs (vc1–vc5, no M11) that omit these columns on upsert still satisfy it via the
-- server default; on update, unsent columns stay unchanged. RLS/grants unchanged:
-- this only adds columns, covered by the existing owner policies (0002).
--
-- Numbered 0011 (not 0006): the live shared DB already carries the parallel M11
-- branch's 0006–0010 (applied out-of-band, not in the CLI ledger which shows 0005).
-- Reusing 0006 would bind that version to different content and be skipped by the
-- CLI. 0011 sits above every M11 file, so no number is ever reused.
--
-- FOLLOW-UP (not in this migration): mirror these columns in drift and have the repo
-- set created_at on insert, so OFFLINE-created rows carry the true device creation
-- time instead of the server-side first-sync time. Until then new rows get the
-- server default — acceptable for current analytics tolerance.

do $$
declare
  t text;
  user_entities text[] := array[
    'profile', 'area', 'user_plant', 'task', 'note', 'supply', 'recipe'
  ];
begin
  foreach t in array user_entities loop
    -- created_at (device-owned, server default as safety net)
    execute format('alter table %I add column if not exists created_at timestamptz', t);
    execute format('update %I set created_at = updated_at where created_at is null', t);
    execute format('alter table %I alter column created_at set default now()', t);
    execute format('alter table %I alter column created_at set not null', t);

    -- server_inserted_at (server-owned ingestion time)
    execute format('alter table %I add column if not exists server_inserted_at timestamptz', t);
    execute format('update %I set server_inserted_at = updated_at where server_inserted_at is null', t);
    execute format('alter table %I alter column server_inserted_at set default now()', t);
    execute format('alter table %I alter column server_inserted_at set not null', t);
  end loop;
end $$;
