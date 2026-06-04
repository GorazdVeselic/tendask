# Supabase — schema & migrations

The cloud schema **mirrors** the local drift database (`lib/core/database/tables/*`).
Model source of truth: `docs/koncept.md` §7.14. Migrations are **additive-only**
(see CLAUDE.md → "Sync, čas in shema").

## Files

| File | Step | Contents |
|---|---|---|
| `migrations/0001_schema.sql` | M5.2 | Tables (catalog + user), inter-table FKs, CHECKs, indexes. |
| `migrations/0002_rls.sql` | M5.3 | `user_id → auth.users` FK, `ON DELETE CASCADE` (GDPR), RLS policies. |

> Order matters: `0001` first, `0002` immediately after. Tables from `0001` have no
> RLS — **do not expose the project** until `0002` is applied too.

## Drift ↔ Supabase mirroring

- `sync_status` (drift) is **local only** — it does NOT exist in the cloud.
- JSON (`labels`/`weather`/`recurrence`/`items`) = `jsonb`; time = `timestamptz` (UTC);
  user `id`/`user_id` = `uuid`; catalog `id` = `text` (seed slug).
- `updated_at` is owned by the device (LWW key) — there is deliberately **no server-side
  trigger** rewriting it (that would corrupt pull ordering).
- When a drift table changes, **update here too** (a new additive migration).

## Applying

Without the Supabase CLI (MVP): open **Supabase Studio → SQL Editor**, paste each
migration in order and run. Or via CLI: `supabase db push` (if/when we wire the CLI).
