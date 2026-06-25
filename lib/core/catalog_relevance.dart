/// Whether a plant [category] is relevant to the chosen task type, given the
/// set of categories that type applies to (category_task_type) — the T3 soft
/// lift in the entry flow.
///
/// An empty [relevant] set means no type is chosen yet, or the type has no
/// matrix entry → everything is relevant (no soft sort). A null [category]
/// (a custom plant, or a catalog row not loaded) is relevant too: unknown is
/// not the same as unrelated, and the picker must never demote a legitimate
/// edge case below the "less likely" divider.
bool isCategoryRelevant(Set<String> relevant, String? category) {
  if (relevant.isEmpty) return true;
  if (category == null) return true;
  return relevant.contains(category);
}
