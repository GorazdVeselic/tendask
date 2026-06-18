import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/location/place_label_repository.dart';
import 'package:tendask/core/location/reverse_geocoding_client.dart';

// Canned H3: the native library can't load under `flutter test` (FFI), so the
// centroid is fixed. The reverse call is faked, so the exact point is irrelevant.
class _FakeH3 implements H3 {
  @override
  GeoCoord cellToGeo(BigInt h3Index) => const GeoCoord(lat: 46.05, lon: 14.51);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeReverseClient extends ReverseGeocodingClient {
  _FakeReverseClient({this.result, this.fails = false}) : super(Dio());

  final String? result;
  final bool fails;
  int calls = 0;
  String? lastLanguage;

  @override
  Future<String?> reverseName(
    double latitude,
    double longitude, {
    String language = 'en',
  }) async {
    calls++;
    lastLanguage = language;
    if (fails) {
      throw DioException(requestOptions: RequestOptions(path: 'reverse'));
    }
    return result;
  }
}

void main() {
  late AppDatabase db;

  const cellA = '871f8d4ffffffff';
  const cellB = '871f8d4efffffff';

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  group('PlaceLabelRepository', () {
    test('save then load round-trips the cell, label and lang', () async {
      final repo = PlaceLabelRepository(db);
      await repo.save((cell: cellA, label: 'Trzin', lang: 'sl'));
      expect(await repo.load(), (cell: cellA, label: 'Trzin', lang: 'sl'));
    });

    test('load returns null when nothing is stored', () async {
      expect(await PlaceLabelRepository(db).load(), isNull);
    });

    test('load returns null on an unparseable cached value', () async {
      await db
          .into(db.localFlags)
          .insert(
            LocalFlagsCompanion.insert(key: 'place_label', value: 'not-json'),
          );
      expect(await PlaceLabelRepository(db).load(), isNull);
    });
  });

  group('placeLabel provider', () {
    ProviderContainer makeContainer({
      required String? cell,
      required _FakeReverseClient client,
    }) {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
          h3Provider.overrideWith((ref) => _FakeH3()),
          gardenCellProvider.overrideWith((ref) => Stream.value(cell)),
          reverseGeocodingClientProvider.overrideWith((ref) => client),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    // A bare `read(...future)` can dispose the autoDispose provider mid-load; a
    // listener keeps it mounted until the async resolves.
    Future<String?> readLabel(ProviderContainer container, String lang) {
      final sub = container.listen(placeLabelProvider(lang), (_, _) {});
      addTearDown(sub.close);
      return container.read(placeLabelProvider(lang).future);
    }

    test('returns null and skips the network when no location is set', () async {
      final client = _FakeReverseClient(result: 'Trzin');
      final container = makeContainer(cell: null, client: client);
      expect(await readLabel(container, 'sl'), isNull);
      expect(client.calls, 0);
    });

    test('resolves and caches on a miss', () async {
      final client = _FakeReverseClient(result: 'Trzin');
      final container = makeContainer(cell: cellA, client: client);
      expect(await readLabel(container, 'sl'), 'Trzin');
      expect(client.calls, 1);
      expect(client.lastLanguage, 'sl');
      expect(await PlaceLabelRepository(db).load(), (
        cell: cellA,
        label: 'Trzin',
        lang: 'sl',
      ));
    });

    test('a cache hit for the same cell and lang needs no network', () async {
      await PlaceLabelRepository(
        db,
      ).save((cell: cellA, label: 'Trzin', lang: 'sl'));
      final client = _FakeReverseClient(result: 'WRONG');
      final container = makeContainer(cell: cellA, client: client);
      expect(await readLabel(container, 'sl'), 'Trzin');
      expect(client.calls, 0);
    });

    test('a different language re-resolves even for the same cell', () async {
      await PlaceLabelRepository(
        db,
      ).save((cell: cellA, label: 'Trzin', lang: 'sl'));
      final client = _FakeReverseClient(result: 'Trzin (de)');
      final container = makeContainer(cell: cellA, client: client);
      expect(
        await readLabel(container, 'de'),
        'Trzin (de)',
      );
      expect(client.calls, 1);
    });

    test('offline falls back to the last-known label for the same cell',
        () async {
      await PlaceLabelRepository(
        db,
      ).save((cell: cellA, label: 'Trzin', lang: 'sl'));
      final client = _FakeReverseClient(fails: true);
      // Same cell, different lang → forces the network path, which then fails.
      final container = makeContainer(cell: cellA, client: client);
      expect(await readLabel(container, 'de'), 'Trzin');
      expect(client.calls, 1);
    });

    test('offline shows no label when the cached one is for another cell',
        () async {
      await PlaceLabelRepository(
        db,
      ).save((cell: cellB, label: 'Old place', lang: 'sl'));
      final client = _FakeReverseClient(fails: true);
      final container = makeContainer(cell: cellA, client: client);
      expect(await readLabel(container, 'sl'), isNull);
    });

    test('a response with no usable name yields null (nothing cached)', () async {
      final client = _FakeReverseClient(result: null);
      final container = makeContainer(cell: cellA, client: client);
      expect(await readLabel(container, 'sl'), isNull);
      expect(await PlaceLabelRepository(db).load(), isNull);
    });
  });
}
