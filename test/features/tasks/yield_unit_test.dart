import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/yield_unit.dart';

void main() {
  group('yieldUnitFromName', () {
    test('parses every known unit by its name', () {
      for (final unit in YieldUnit.values) {
        expect(yieldUnitFromName(unit.name), unit);
      }
    });

    test('null name returns null', () {
      expect(yieldUnitFromName(null), isNull);
    });

    test('unknown value returns null (tolerant, never throws)', () {
      expect(yieldUnitFromName('tonnes'), isNull);
      expect(yieldUnitFromName(''), isNull);
      expect(yieldUnitFromName('KG'), isNull); // case-sensitive on enum name
    });

    test('default unit is kg', () {
      expect(kDefaultYieldUnit, YieldUnit.kg);
    });
  });
}
