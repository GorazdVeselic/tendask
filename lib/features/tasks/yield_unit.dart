/// Units a harvest yield can be recorded in (T11). Stored on `task.yield_unit`
/// as the enum name; mirrored verbatim to Supabase (no migration on add).
enum YieldUnit { kg, dag, g, pieces, l, bunch }

/// Prefilled unit when the user first opens the yield input.
const kDefaultYieldUnit = YieldUnit.kg;

/// Parses a stored unit name back to a [YieldUnit]. Tolerant by design: an
/// unknown value (a unit added by a newer app version, pulled onto an older one)
/// or null returns null instead of throwing — same rule as the sync parser.
YieldUnit? yieldUnitFromName(String? name) {
  if (name == null) return null;
  for (final unit in YieldUnit.values) {
    if (unit.name == name) return unit;
  }
  return null;
}
