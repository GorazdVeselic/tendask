/// Supply category. Stored as the enum name (`fertilizer` / `treatment` / …)
/// via drift `textEnum`, so the on-disk and Supabase string values stay stable.
/// Declaration order is the grouping/UI order; `other` is the catch-all bucket
/// (existing rows backfill to it).
enum SupplyCategory { fertilizer, treatment, equipment, other }
