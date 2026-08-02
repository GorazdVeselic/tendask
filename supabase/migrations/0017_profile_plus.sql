-- 0017 — FR-20 (Tendask+): entitlement columns on profile.
-- Spec: docs/feature-requests/tendask-plus-licensing.md §6.2 + §7.
--
--   plus_until  timestamptz — the ONLY source of entitlement (now < plus_until).
--   plus_token  text        — signed JWT proving plus_until; verified on-device
--                             against the bundled public key (§6.2, the real wall).
--   plus_kind   text        — annual|lifetime|gift|granted, DISPLAY ONLY
--                             ("Lifetime" vs "valid until …"); never read for
--                             entitlement, or there would be two truths.
--
-- The license* tables are NOT part of this slice (they arrive with the store, §12):
-- the launch grant writes plus_until straight onto the profile (§6.6-C).
--
-- Additive + nullable + idempotent: released APKs ignore unknown columns on pull
-- and never send them on push, so nothing crashes and no rollback is needed.
--
-- Numbering: the ledger holds 0001–0005 and 0011–0016 (verified read-only against
-- production 2026-08-02), so 0017 is the next free number. The 0006–0010 gap
-- belongs to an abandoned branch whose migrations never reached any database.

alter table profile
  add column if not exists plus_until timestamptz,
  add column if not exists plus_token text,
  add column if not exists plus_kind  text;

-- ============================================================
-- Server-owned columns — column-level write lockdown
-- ============================================================
-- Entitlement must not be writable by the device even from a tampered client: the
-- anon key ships inside the APK and the user's JWT is legitimate, so a hand-written
-- PostgREST call — not our own sync code — is the realistic attack.
--
-- RLS cannot express this: profile_owner (0002) is row-level and therefore covers
-- every column. Grants are the only column-aware gate PostgREST honours.
--
-- ⚠️ `revoke update (plus_until, plus_token) on profile from authenticated` — the
-- shape the spec sketches — is a NO-OP here. Privileges only ever add up, and 0002
-- granted UPDATE on the WHOLE table; a column-level revoke cannot subtract from a
-- table-level grant. The only working shape is: drop the table-level grant, then
-- re-grant column by column, which is what this block does.
--
-- INSERT is locked down together with UPDATE, not after it: an upsert whose row
-- does not exist yet is an INSERT, and DELETE + INSERT would otherwise walk
-- straight around an UPDATE-only lock.
--
-- anon is revoked too: Supabase's default privileges can grant ALL on tables to
-- anon/authenticated on top of an explicit grant. RLS already blocks anon on
-- profile; this makes it true at the grant level as well. service_role is left
-- untouched — it is what writes plus_* (webhook / launch grant).
--
-- ⚠️ MAINTENANCE: the columns granted below are the complete client-writable set;
-- the four server-owned ones are simply absent. Every later migration that adds a
-- client-written column to profile must add it here too (`grant insert (col),
-- update (col) on profile to authenticated`) — otherwise push fails with 42501 and
-- blocks the whole sync chain.
--   server-owned: plus_until, plus_token, plus_kind
--                 server_inserted_at — 0011 declares it server-owned ("the device
--                 never sends it"); it stayed writable only because the 0002 grant
--                 predates it.

revoke insert, update on profile from anon, authenticated;

grant insert (
  user_id, h3_r7, h3_r6, h3_r5, lang, notification_settings,
  default_garden_seeded, created_at, updated_at
) on profile to authenticated;

grant update (
  user_id, h3_r7, h3_r6, h3_r5, lang, notification_settings,
  default_garden_seeded, created_at, updated_at
) on profile to authenticated;
