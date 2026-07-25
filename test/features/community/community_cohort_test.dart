import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/community/data/community_cohort.dart';
import 'package:tendask/features/community/data/community_models.dart';

final _t = DateTime.utc(2026, 5, 1);

UserPlant _userPlant(String id, {String? plantId, bool isCustom = false}) =>
    UserPlant(
      id: id,
      userId: 'local',
      plantId: plantId,
      isCustom: isCustom,
      updatedAt: _t,
      deleted: false,
      syncStatus: 'synced',
    );

TaskSubject _subject(
  String id, {
  String? userPlantId,
  String? areaId,
  bool deleted = false,
}) => TaskSubject(
  id: id,
  taskId: 'task-1',
  userPlantId: userPlantId,
  areaId: areaId,
  updatedAt: _t,
  deleted: deleted,
  syncStatus: 'synced',
);

CommunityFeedItem _item(String taskTypeId, String cohort) => CommunityFeedItem(
  taskTypeId: taskTypeId,
  cohort: cohort,
  distinctUsers7d: 5,
  intensity: CommunityIntensity.some,
);

void main() {
  group('cohortOfSubjects', () {
    test('a catalog plant compares within its species', () {
      final cohort = cohortOfSubjects(
        [_subject('s1', userPlantId: 'up1')],
        {'up1': _userPlant('up1', plantId: 'apple')},
      );

      expect(cohort, 'apple');
    });

    test('an area is site work', () {
      final cohort = cohortOfSubjects([_subject('s1', areaId: 'lawn')], const {});

      expect(cohort, kCommunityCohortSite);
    });

    test('a private custom plant is site work, never a group of one', () {
      final cohort = cohortOfSubjects(
        [_subject('s1', userPlantId: 'up1')],
        {'up1': _userPlant('up1', plantId: 'apple', isCustom: true)},
      );

      expect(cohort, kCommunityCohortSite);
    });

    test('no subject at all is site work', () {
      expect(cohortOfSubjects(const [], const {}), kCommunityCohortSite);
    });

    test('a deleted subject does not decide the cohort', () {
      final cohort = cohortOfSubjects(
        [
          _subject('s1', userPlantId: 'up1', deleted: true),
          _subject('s2', userPlantId: 'up2'),
        ],
        {
          'up1': _userPlant('up1', plantId: 'apple'),
          'up2': _userPlant('up2', plantId: 'plum'),
        },
      );

      expect(cohort, 'plum');
    });
  });

  group('pickHomeHint', () {
    test('prefers the busiest row about a species this garden grows', () {
      final hint = pickHomeHint([
        _item('water', kCommunityCohortSite),
        _item('prune', 'apple'),
        _item('sow', 'tomato'),
      ], {'tomato', 'apple'});

      // Ranking already put the busiest first, so the first match wins.
      expect(hint?.cohort, 'apple');
    });

    test('falls back to the busiest row when nothing matches the garden', () {
      final hint = pickHomeHint([
        _item('water', kCommunityCohortSite),
        _item('prune', 'apple'),
      ], {'tomato'});

      expect(hint?.taskTypeId, 'water');
    });

    test('site rows never count as personal, only as the fallback', () {
      final hint = pickHomeHint([
        _item('mow', kCommunityCohortSite),
        _item('sow', 'tomato'),
      ], {'tomato', kCommunityCohortSite});

      expect(hint?.cohort, 'tomato');
    });

    test('an empty feed has no hint', () {
      expect(pickHomeHint(const [], const {'apple'}), isNull);
    });
  });
}
