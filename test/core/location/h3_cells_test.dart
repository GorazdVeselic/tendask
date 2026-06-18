import 'package:flutter_test/flutter_test.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:tendask/core/location/h3_cells.dart';

// The real H3 instance needs the native h3 library (FFI), which isn't available
// under `flutter test` on the host — so we fake the one method cellCentroid uses
// (cellToGeo). The actual H3 math (centroid stays inside the cell) is verified
// on-device; here we lock down the wrapper's parsing + lat/lon mapping.
class _FakeH3 implements H3 {
  _FakeH3(this._geo);

  final GeoCoord Function(BigInt cell) _geo;
  BigInt? lastCell;

  @override
  GeoCoord cellToGeo(BigInt h3Index) {
    lastCell = h3Index;
    return _geo(h3Index);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  group('cellCentroid', () {
    test('returns null for null / empty / non-hex without calling cellToGeo', () {
      final h3 = _FakeH3((_) => fail('cellToGeo must not be called'));
      expect(cellCentroid(h3, null), isNull);
      expect(cellCentroid(h3, ''), isNull);
      expect(cellCentroid(h3, 'not-hex-zz'), isNull);
    });

    test('parses the hex cell and maps GeoCoord lon/lat to coords', () {
      final h3 = _FakeH3((_) => const GeoCoord(lat: 46.05, lon: 14.51));
      final coords = cellCentroid(h3, '871f8d4ffffffff');
      expect(coords, isNotNull);
      // GeoCoord normalizes lat/lon (mod arithmetic), so allow FP slack.
      expect(coords!.latitude, closeTo(46.05, 1e-9));
      expect(coords.longitude, closeTo(14.51, 1e-9));
      // The stored cell is canonical lowercase hex → BigInt(radix 16).
      expect(h3.lastCell, BigInt.parse('871f8d4ffffffff', radix: 16));
    });
  });

  test('H3 resolution constants are r7 > r6 > r5', () {
    expect(kH3ResR7, 7);
    expect(kH3ResR6, 6);
    expect(kH3ResR5, 5);
  });
}
