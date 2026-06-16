import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/areas/presentation/areas_screen.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/i18n/translations.g.dart';

Area _area(String id, String name, AreaType type) => Area(
  id: id,
  userId: 'u1',
  name: name,
  type: type,
  protected: false,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('empty garden shows both add CTAs (first run)', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            areasListProvider.overrideWith((ref) => Stream.value(<Area>[])),
            latestTaskPerAreaProvider.overrideWith(
              (ref) => Stream.value(<String, Task>{}),
            ),
            taskTypesMapProvider.overrideWith(
              (ref) => Stream.value(<String, TaskType>{}),
            ),
            userPlantsMapProvider.overrideWith(
              (ref) => Stream.value(<String, UserPlant>{}),
            ),
            plantsMapProvider.overrideWith(
              (ref) => Stream.value(<String, Plant>{}),
            ),
          ],
          child: const MaterialApp(home: AreasScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.areas.empty_title), findsOneWidget);
    expect(find.text(t.areas.empty_cta_plant), findsOneWidget);
    expect(find.text(t.areas.empty_cta_area), findsOneWidget);
  });

  testWidgets('garden section renders before other area types', (tester) async {
    // Deliberately list bed before garden to prove ordering follows the enum
    // (AreaType.values), not insertion order.
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            areasListProvider.overrideWith(
              (ref) => Stream.value([
                _area('b1', 'Greda', AreaType.bed),
                _area('g1', 'Vrt', AreaType.garden),
              ]),
            ),
            latestTaskPerAreaProvider.overrideWith(
              (ref) => Stream.value(<String, Task>{}),
            ),
            taskTypesMapProvider.overrideWith(
              (ref) => Stream.value(<String, TaskType>{}),
            ),
            userPlantsMapProvider.overrideWith(
              (ref) => Stream.value(<String, UserPlant>{}),
            ),
            plantsMapProvider.overrideWith(
              (ref) => Stream.value(<String, Plant>{}),
            ),
          ],
          child: const MaterialApp(home: AreasScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Section labels are uppercased by SectionLabel.
    final gardenY = tester
        .getTopLeft(find.text(t.areas.type_garden.toUpperCase()))
        .dy;
    final bedY = tester.getTopLeft(find.text(t.areas.type_bed.toUpperCase())).dy;
    expect(gardenY, lessThan(bedY));
  });
}
