import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/features/moon/application/garden_elements_provider.dart';
import 'package:tendask/features/plants/data/user_plants_repository.dart';

/// The ★ highlight over a real catalog: what the user actually grows decides
/// which element days are marked (spec §6.3.8).
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late UserPlantsRepository plants;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedService(db).runIfNeeded(); // bundled catalog (141 plants)
    plants = UserPlantsRepository(db);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    // A stream provider only starts on subscription (and must stay alive).
    addTearDown(container.listen(gardenElementsProvider, (_, _) {}).close);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<Set<BiodynamicElement>> elements() async {
    // The garden set is derived from two drift watches; let them deliver
    // before reading it.
    await pumpEventQueue(times: 30);
    return container.read(gardenElementsProvider);
  }

  test('an empty garden marks nothing', () async {
    expect(await elements(), isEmpty);
  });

  test('catalog plants resolve to their sowing-calendar element', () async {
    await plants.create(userId: kLocalUserId, plantId: 'tomato');
    await plants.create(userId: kLocalUserId, plantId: 'carrot');

    expect(await elements(), {
      BiodynamicElement.fruit,
      BiodynamicElement.root,
    });
  });

  test('a custom plant carries no recommendation', () async {
    await plants.create(userId: kLocalUserId, customName: 'skrivnostna rastlina');

    expect(await elements(), isEmpty);
  });

  test('categories outside the sowing calendar stay unmarked', () async {
    // Houseplants have no element by decision (kCategoryNoElement).
    await plants.create(userId: kLocalUserId, plantId: 'ficus');

    expect(await elements(), isEmpty);
  });

  test('a deleted plant stops marking its element', () async {
    final id = await plants.create(userId: kLocalUserId, plantId: 'tomato');
    expect(await elements(), {BiodynamicElement.fruit});

    await plants.softDelete(id);

    expect(await elements(), isEmpty);
  });
}
