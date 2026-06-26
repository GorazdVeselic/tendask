import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/plants/data/user_plants_repository.dart';
import 'package:tendask/features/plants/presentation/garden_plant_add_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

// SectionLabel uppercases its text, so the divider is matched in CAPS.
const _lessLikely = 'MANJ VERJETNO ZA TO OBMOČJE';

Plant _plant(String id, String label, String category) =>
    Plant(id: id, labels: jsonEncode({'sl': label}), category: category);

/// Inserts one typed area and returns it as the `areasMapProvider` value. The
/// in-memory db only backs `recentPlantIds()` (one-shot future, no watch timer).
Future<(AppDatabase, Map<String, Area>)> _setup(AreaType type) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db
      .into(db.areas)
      .insert(
        AreasCompanion.insert(
          id: 'area-1',
          userId: 'local',
          name: 'Test',
          type: Value(type),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
  final areas = {for (final a in await db.select(db.areas).get()) a.id: a};
  return (db, areas);
}

Future<void> _pump(
  WidgetTester tester,
  AppDatabase db,
  Map<String, Area> areas,
  List<Plant> plants,
) async {
  final plantsMap = {for (final p in plants) p.id: p};
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          userPlantsRepositoryProvider.overrideWithValue(
            UserPlantsRepository(db),
          ),
          areasMapProvider.overrideWith((ref) => Stream.value(areas)),
          userPlantsMapProvider.overrideWith(
            (ref) => Stream.value(<String, UserPlant>{}),
          ),
          plantsMapProvider.overrideWith((ref) => Stream.value(plantsMap)),
          plantsListProvider.overrideWith((ref) => Stream.value(plants)),
        ],
        child: const MaterialApp(
          home: GardenPlantAddScreen(args: PlantAddArgs(areaId: 'area-1')),
        ),
      ),
    ),
  );
  await tester.pump(); // build
  await tester.pump(
    const Duration(milliseconds: 100),
  ); // streams + recent future
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('typed area (tree) lifts relevant plants above a divider', (
    tester,
  ) async {
    final (db, areas) = await _setup(AreaType.tree);
    addTearDown(db.close);

    await _pump(tester, db, areas, [
      _plant('apple', 'Jablana', 'fruit_tree'),
      _plant('tomato', 'Paradižnik', 'vegetable'),
    ]);

    // Both stay reachable; the irrelevant one is demoted, not hidden.
    expect(find.text(_lessLikely), findsOneWidget);
    expect(find.text('Jablana'), findsOneWidget);
    expect(find.text('Paradižnik'), findsOneWidget);

    final relevantDy = tester.getTopLeft(find.text('Jablana')).dy;
    final dividerDy = tester.getTopLeft(find.text(_lessLikely)).dy;
    final otherDy = tester.getTopLeft(find.text('Paradižnik')).dy;
    expect(relevantDy, lessThan(dividerDy));
    expect(dividerDy, lessThan(otherDy));
  });

  testWidgets('garden area is catch-all — no divider', (tester) async {
    final (db, areas) = await _setup(AreaType.garden);
    addTearDown(db.close);

    await _pump(tester, db, areas, [
      _plant('apple', 'Jablana', 'fruit_tree'),
      _plant('tomato', 'Paradižnik', 'vegetable'),
    ]);

    expect(find.text(_lessLikely), findsNothing);
    expect(find.text('Jablana'), findsOneWidget);
    expect(find.text('Paradižnik'), findsOneWidget);
  });
}
