import 'dart:convert';

/// One supply (by id) and the amount it contributes to a recipe. Stored as part
/// of the `recipe.items` JSON array; the unit is derived from the supply, not
/// duplicated here.
class RecipeItem {
  const RecipeItem({required this.supplyId, required this.amount});

  final String supplyId;
  final double amount;

  /// Tolerant parse of one `recipe.items` element — returns null for anything
  /// malformed (missing id, non-positive amount) so a bad entry is dropped, not
  /// fatal.
  static RecipeItem? _tryFromMap(Object? raw) {
    if (raw is! Map) return null;
    final supplyId = raw['supply_id'];
    final amount = (raw['amount'] as num?)?.toDouble();
    if (supplyId is! String || supplyId.isEmpty) return null;
    if (amount == null || amount <= 0) return null;
    return RecipeItem(supplyId: supplyId, amount: amount);
  }

  Map<String, dynamic> _toMap() => {'supply_id': supplyId, 'amount': amount};

  @override
  bool operator ==(Object other) =>
      other is RecipeItem &&
      other.supplyId == supplyId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(supplyId, amount);
}

/// Tolerant decode of the `recipe.items` JSON column. Null/empty/malformed → [].
List<RecipeItem> parseRecipeItems(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return const [];
  }
  if (decoded is! List) return const [];
  return decoded
      .map(RecipeItem._tryFromMap)
      .whereType<RecipeItem>()
      .toList(growable: false);
}

/// JSON for the repository (the inverse of [parseRecipeItems]).
String encodeRecipeItems(List<RecipeItem> items) =>
    jsonEncode(items.map((i) => i._toMap()).toList());
