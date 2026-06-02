/// Area category. Stored as the enum name (`lawn` / `hedge` / …) via drift
/// `textEnum`, so the on-disk and Supabase string values stay stable.
enum AreaType { lawn, hedge, bed, tree, ornamental, other }
