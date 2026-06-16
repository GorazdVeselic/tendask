-- Tendask — FR-9: allow the default "garden" area type.
-- Mirrors lib/core/area_type.dart (enum AreaType { garden, lawn, ... }) and the
-- drift textEnum column, which already emit 'garden'. Without this, the seeded
-- default garden (area.type = 'garden', sync_status = pending) fails the CHECK
-- on push (Postgres 23514), and because the push is fail-fast that aborts the
-- whole sync cycle for the signed-in user.
--
-- Expand-safe (CLAUDE.md "Sync, čas in shema" — additive-only): the allowed set
-- only grows, so no existing row can violate it and older APKs (which never emit
-- 'garden') keep working. Idempotent — re-runnable. RLS/grants unchanged: this
-- only edits a CHECK constraint, not column access.
--
-- Numbered 0010 (not 0005): the live shared DB already has 0005–0009 applied
-- from the parallel M11 branch, so reusing those numbers would conflict.

alter table area drop constraint if exists area_type_check;
alter table area add constraint area_type_check
  check (type in ('garden', 'lawn', 'hedge', 'bed', 'tree', 'ornamental', 'other'));
