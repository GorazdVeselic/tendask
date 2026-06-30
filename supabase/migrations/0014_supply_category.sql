-- Tendask — supplies tracking: supply.category groups the supplies list (08).
-- Mirrors drift supply.category (lib/core/database/tables/user_tables.dart) and
-- schema v12 (lib/core/database/app_database.dart).
--
-- Why: the supplies screen groups stock into Fertilizers / Treatments /
-- Equipment / Other. The category is stored as the enum name (mirrors the Dart
-- SupplyCategory enum) so the on-disk, drift and cloud strings stay identical.
--
-- Additive-only (runbook §2): NOT NULL with a default, so existing rows backfill
-- to 'other' in the same migration and old APKs that omit the column on push
-- still insert cleanly (the default fills it). The tolerant parser ignores the
-- extra column on pull. RLS unchanged — the supply owner policy (0002) covers
-- all columns; the table grant from 0001/0002 already covers every column.
--
-- A CHECK mirrors the app enum so a client bug can't store an unknown category
-- (DB-level invariant, CLAUDE.md). All backfilled rows are 'other' → it holds.

alter table supply
  add column if not exists category text not null default 'other';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'supply_category_check'
  ) then
    alter table supply
      add constraint supply_category_check
      check (category in ('fertilizer', 'treatment', 'equipment', 'other'));
  end if;
end $$;
