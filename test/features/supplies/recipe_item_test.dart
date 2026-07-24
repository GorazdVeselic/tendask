import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/supplies/data/recipe_item.dart';

void main() {
  test('encode then parse round-trips', () {
    const items = [
      RecipeItem(supplyId: 'a', amount: 100),
      RecipeItem(supplyId: 'b', amount: 2.5),
    ];
    expect(parseRecipeItems(encodeRecipeItems(items)), items);
  });

  test('null / empty / malformed JSON degrade to empty list', () {
    expect(parseRecipeItems(null), isEmpty);
    expect(parseRecipeItems(''), isEmpty);
    expect(parseRecipeItems('{not json'), isEmpty);
    expect(parseRecipeItems('{"supply_id":"a"}'), isEmpty); // object, not list
  });

  test('drops malformed elements but keeps valid ones', () {
    final items = parseRecipeItems(
      '[{"supply_id":"a","amount":3},'
      '{"supply_id":"","amount":1},' // empty id
      '{"supply_id":"b","amount":0},' // non-positive amount
      '{"amount":5},' // missing id
      '{"supply_id":"c","amount":1.5}]',
    );
    expect(items, const [
      RecipeItem(supplyId: 'a', amount: 3),
      RecipeItem(supplyId: 'c', amount: 1.5),
    ]);
  });
}
