/// Area category. Stored as the enum name (`garden` / `lawn` / …) via drift
/// `textEnum`, so the on-disk and Supabase string values stay stable — the
/// declaration order is the UI order, so `garden` (the default whole-garden
/// area) comes first.
enum AreaType { garden, lawn, hedge, bed, tree, ornamental, other }
