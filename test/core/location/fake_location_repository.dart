import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/location/place_label_repository.dart';
import 'package:tendask/i18n/translations.g.dart';

/// The garden location, in memory: enough for widgets that read the stored cell
/// and write a new one, without drift and without the native H3 library (whose
/// FFI cannot load under `flutter test`).
class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({this.cell});

  /// The cell every save lands on. Its value is irrelevant to callers — only
  /// set vs. unset is — so one constant stands in for the real derivation.
  static const savedCell = '871f8d4ffffffff';

  /// The stored r7 cell, null while no location is set.
  String? cell;

  /// Coordinates passed to [saveGardenLocation], oldest first: they are never
  /// persisted (FR-8), so this is the only way to assert what the screen sent.
  final saved = <({double latitude, double longitude})>[];

  @override
  Future<void> saveGardenLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    saved.add((latitude: latitude, longitude: longitude));
    cell = savedCell;
  }

  @override
  Future<void> clearGardenLocation(String userId) async => cell = null;

  @override
  Future<String?> gardenCell() async => cell;

  @override
  Stream<String?> watchGardenCell() => Stream.value(cell);
}

/// Everything the location screen reads about a garden location: the repository
/// above, plus a canned place label for every locale — the real one reverse-
/// geocodes over the network, which no widget test should reach.
List<Override> locationOverrides(
  FakeLocationRepository repository, {
  String? placeLabel,
}) => [
  locationRepositoryProvider.overrideWithValue(repository),
  for (final locale in AppLocale.values)
    placeLabelProvider(
      locale.languageCode,
    ).overrideWith((ref) async => placeLabel),
];
