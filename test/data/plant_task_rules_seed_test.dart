import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/data/seed/catalog_seed.dart';
import 'package:tendask/data/seed/plant_task_rules_seed.dart';

// Guard code dictionary — docs/m11/02-signalni-sloj.md §G.
const _guardCodes = {
  'dry12h',
  'dry24h',
  'no_rain_forecast_24h',
  'no_rain_forecast_48h',
  'no_heavy_rain_24h',
  'wind_lt_15',
  'wind_lt_20',
  'temp_gt_0',
  'temp_gt_5',
  'temp_lt_30',
  'soil_gt_8',
  'soil_gt_10',
  'soil_gt_12',
  'soil_moist',
  'no_frost_forecast_48h',
  'drought7d',
};

void main() {
  final rules = PlantTaskRulesSeed.rules;
  final taskTypeIds = CatalogSeed.taskTypes.map((t) => t.id).toSet();
  final plantIds = CatalogSeed.plants.map((p) => p.id).toSet();
  final categories = CatalogSeed.plants.map((p) => p.category).toSet();

  test('seed has the M11 scope (61 rules, unique ids)', () {
    expect(rules.length, 61);
    expect(rules.map((r) => r.id).toSet().length, rules.length);
  });

  test('every rule references existing catalog ids', () {
    for (final r in rules) {
      expect(
        taskTypeIds,
        contains(r.taskTypeId),
        reason: '${r.id}: unknown task_type ${r.taskTypeId}',
      );
      expect(['plant', 'category'], contains(r.scope), reason: r.id);
      final validRefs = r.scope == 'plant' ? plantIds : categories;
      expect(
        validRefs,
        contains(r.refId),
        reason: '${r.id}: unknown ref_id ${r.refId} for scope ${r.scope}',
      );
    }
  });

  test('source_ref is a confirmed citation (no verify markers)', () {
    for (final r in rules) {
      expect(r.sourceRef.trim(), isNotEmpty, reason: r.id);
      expect(
        r.sourceRef.contains('(verify') || r.sourceRef.contains('TODO'),
        isFalse,
        reason: '${r.id}: unverified source must not be seeded',
      );
    }
  });

  test('confidence and message_key match the schema contract', () {
    for (final r in rules) {
      expect(['high', 'medium'], contains(r.confidence), reason: r.id);
      expect(r.messageKey, startsWith('suggestions.'), reason: r.id);
    }
  });

  test('weather_guard codes come from the §G dictionary', () {
    for (final r in rules) {
      final guard = r.weatherGuard;
      if (guard == null) continue;
      for (final code in guard.split(',')) {
        expect(
          _guardCodes,
          contains(code.trim()),
          reason: '${r.id}: unknown guard code "$code"',
        );
      }
    }
  });

  test('window JSON is valid for its timing anchor', () {
    for (final r in rules) {
      final w = jsonDecode(r.window) as Map<String, dynamic>;
      switch (r.timingAnchor) {
        case 'month_window':
          final start = w['start_week'] as int;
          final end = w['end_week'] as int;
          expect(start, inInclusiveRange(1, 53), reason: r.id);
          expect(end, inInclusiveRange(start, 53), reason: r.id);
          expect(w.containsKey('climate_bucket_filter'), isTrue, reason: r.id);
          expect(
            ['spring', 'autumn', 'none'],
            contains(w['regionalize']),
            reason: r.id,
          );
        case 'frost_offset':
          expect(
            ['last_frost', 'first_frost'],
            contains(w['anchor']),
            reason: r.id,
          );
          final min = w['offset_min_days'] as int;
          final max = w['offset_max_days'] as int;
          expect(min, lessThanOrEqualTo(max), reason: r.id);
        case 'growth_stage':
          expect(
            taskTypeIds,
            contains(w['after_event']),
            reason: '${r.id}: after_event must be a task_type id',
          );
          final min = w['offset_min_days'] as int;
          final max = w['offset_max_days'] as int;
          expect(min, lessThanOrEqualTo(max), reason: r.id);
        case 'cadence_only':
          final min = w['min_days_since_last'] as int;
          final max = w['max_days_since_last'] as int;
          expect(min, lessThanOrEqualTo(max), reason: r.id);
          final seasonStart = w['season_start_week'] as int?;
          final seasonEnd = w['season_end_week'] as int?;
          if (seasonStart != null || seasonEnd != null) {
            expect(seasonStart, isNotNull, reason: r.id);
            expect(seasonEnd, isNotNull, reason: r.id);
            // null-safe: both asserted non-null just above
            expect(seasonStart!, inInclusiveRange(1, 53), reason: r.id);
            expect(seasonEnd!, inInclusiveRange(seasonStart, 53), reason: r.id);
          }
        default:
          fail('${r.id}: unknown timing_anchor ${r.timingAnchor}');
      }
    }
  });

  test('plant overrides only target task types their category also allows', () {
    // The engine overrides category rules per (plant, task_type); a plant rule
    // for a task type outside the category matrix would be unreachable in UI.
    final matrix = CatalogSeed.categoryMatrix.toSet();
    final plantCategory = {for (final p in CatalogSeed.plants) p.id: p.category};
    for (final r in rules.where((r) => r.scope == 'plant')) {
      final category = plantCategory[r.refId];
      expect(
        matrix,
        contains((category, r.taskTypeId)),
        reason: '${r.id}: $category lacks ${r.taskTypeId} in category matrix',
      );
    }
  });
}
