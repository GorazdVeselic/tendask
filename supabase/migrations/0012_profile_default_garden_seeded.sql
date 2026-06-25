-- Tendask — fix: default garden seeded once PER ACCOUNT (not per device).
-- Mirrors drift profile.default_garden_seeded (lib/core/database/tables/user_tables.dart).
--
-- Why: the "already seeded" guard lived only in device-local prefs, which a
-- reinstall wipes — so every fresh install + sign-in re-seeded a garden and
-- pushed a duplicate to the cloud. This per-account flag survives reinstall: on
-- a fresh pull the client learns the account already has its default garden and
-- skips seeding (the local guest garden is dropped before it is ever synced).
--
-- Additive-only + idempotent (runbook §2): NOT NULL with default false is safe —
-- every existing row gets false; old APKs tolerate the extra column (tolerant
-- parser ignores unknown keys on pull, push omits it leaving the value
-- unchanged). RLS unchanged — the profile owner policy (0002) covers all columns.

alter table profile
  add column if not exists default_garden_seeded boolean not null default false;

-- Backfill: an account that already has a (non-deleted) garden-type area has
-- effectively been seeded — mark it so a future reinstall never duplicates it.
-- No updated_at bump: existing installs keep their LWW state untouched (they
-- already hold the garden and never re-seed); a reinstall reads the flag via the
-- full initial pull (cursor = epoch), which fetches every row regardless of time.
update profile p
set default_garden_seeded = true
where exists (
  select 1 from area a
  where a.user_id = p.user_id
    and a.type = 'garden'
    and coalesce(a.deleted, false) = false
);
