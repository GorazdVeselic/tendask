import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/type_ordering.dart';

TaskType _type(String id) => TaskType(
  id: id,
  labels: jsonEncode({'sl': id}),
  icon: '💧',
  category: 'care',
  requiresSubject: false,
  weatherSensitive: false,
  consumesSupplies: false,
  seasonal: true,
  defaultCadence: null,
);

/// Insertion order is the seed order (Dart maps preserve it).
Map<String, TaskType> _catalog(List<String> ids) => {
  for (final id in ids) id: _type(id),
};

void main() {
  group('sortTaskTypesByUsage', () {
    test('orders by usage, most used first', () {
      final sorted = sortTaskTypesByUsage(_catalog(['water', 'prune', 'sow']), {
        'sow': 5,
        'water': 2,
      });

      expect(sorted.map((t) => t.id), ['sow', 'water', 'prune']);
    });

    test('ties keep the seed (insertion) order', () {
      final sorted = sortTaskTypesByUsage(_catalog(['water', 'prune', 'sow']), {
        'water': 3,
        'sow': 3,
      });

      // water and sow tie at 3 → seed order keeps water before sow.
      expect(sorted.map((t) => t.id), ['water', 'sow', 'prune']);
    });

    test('no usage at all leaves the seed order untouched', () {
      final sorted = sortTaskTypesByUsage(
        _catalog(['water', 'prune', 'sow']),
        const {},
      );

      expect(sorted.map((t) => t.id), ['water', 'prune', 'sow']);
    });
  });

  group('ensureSelectedVisible', () {
    final all = [_type('a'), _type('b'), _type('c'), _type('d')];
    final visible = [_type('a'), _type('b')];

    test('an already-visible selection is left as-is', () {
      final result = ensureSelectedVisible(visible, all, 'a');
      expect(result.map((t) => t.id), ['a', 'b']);
    });

    test('no selection leaves the window untouched', () {
      final result = ensureSelectedVisible(visible, all, null);
      expect(result.map((t) => t.id), ['a', 'b']);
    });

    test('a selection outside the window is appended', () {
      final result = ensureSelectedVisible(visible, all, 'd');
      expect(result.map((t) => t.id), ['a', 'b', 'd']);
    });

    test('a selection missing from the catalog changes nothing', () {
      final result = ensureSelectedVisible(visible, all, 'zzz');
      expect(result.map((t) => t.id), ['a', 'b']);
    });
  });
}
