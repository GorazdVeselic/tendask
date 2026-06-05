import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/areas/data/areas_repository.dart';
import 'package:uuid/uuid.dart';

/// Guards invariant #2: device-generated ids are in Postgres' canonical uuid
/// form (lowercase, hyphenated, version 4). Push sends and pull reads the id
/// verbatim, so as long as the source is a canonical v4, the same row never
/// gets two ids (no upsert duplicate / orphan across local↔cloud).
final _canonicalV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  test('Uuid().v4() is canonical (lowercase v4) — matches Postgres uuid output',
      () {
    for (var i = 0; i < 50; i++) {
      expect(const Uuid().v4(), matches(_canonicalV4));
    }
  });

  test('a repository create() yields a canonical id', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await AreasRepository(db).create(
      userId: 'u1',
      name: 'Bed',
      type: AreaType.bed,
    );
    expect(id, matches(_canonicalV4));
  });
}
