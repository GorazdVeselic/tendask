-- Tendask — M8.4: notification settings (screen 22) on the profile, synced LWW.
-- Mirrors drift profile.notification_settings (lib/core/database/tables/user_tables.dart).
--
-- Additive-only (CLAUDE.md "Sync, čas in shema"): nullable jsonb, no backfill needed.
-- Older APKs without this column tolerate it (the client parses jsonb tolerantly,
-- unknown/missing fields fall back to defaults). RLS is unchanged — the existing
-- profile owner policy (0002) already covers all columns.

alter table profile add column if not exists notification_settings jsonb;
