import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/data/seed/plant_task_rules_seed.dart';

/// Guards the suggestion message catalog against the engine's emit contract:
/// a template must only reference {markers} that the engine actually sends for
/// that rule (docs/m11/03 §Sporočila, mirrored from rules_agro.ts). An unsent
/// marker would render empty — e.g. {frost_date} only ships when frost_gate.
void main() {
  final locales = {
    for (final l in ['en', 'sl', 'de'])
      l: (jsonDecode(File('lib/i18n/$l.i18n.json').readAsStringSync())
          as Map<String, dynamic>)['suggestions'] as Map<String, dynamic>,
  };

  // subject + task are always available (the card resolves task from the row).
  Set<String> ruleMarkers(PlantTaskRuleSeed r) => switch (r.timingAnchor) {
    'month_window' || 'frost_offset' => {
      'subject',
      'task',
      'window_end_date',
      if (r.frostGate) 'frost_date',
    },
    'growth_stage' => {'subject', 'task', 'days_since'},
    _ => {'subject', 'task'}, // cadence_only — not emitted; lenient
  };

  // Generic keys (R3/R2/R1/R6) and their params from docs/m11/03.
  final generic = {
    'suggestions.cadence.overdue': {
      'subject',
      'task',
      'days_overdue',
      'cadence_days',
    },
    'suggestions.history.anniversary': {'subject', 'task', 'last_year_date'},
    'suggestions.weather.window_open': {'subject', 'task'},
    'suggestions.community.most_started': {'task', 'percent'}, // no subject
  };

  Map<String, dynamic>? entryFor(Map<String, dynamic> sug, String key) {
    dynamic node = sug;
    for (final part in key.split('.').skip(1)) {
      if (node is! Map<String, dynamic>) return null;
      node = node[part];
    }
    return node is Map<String, dynamic> ? node : null;
  }

  final markerRe = RegExp(r'\{(\w+)\}');
  Set<String> markersIn(Map<String, dynamic> entry) => markerRe
      .allMatches('${entry['title']} ${entry['body']}')
      .map((m) => m.group(1)!)
      .toSet();

  void checkKey(String key, Set<String> allowed) {
    for (final entry in locales.entries) {
      final node = entryFor(entry.value, key);
      expect(
        node,
        isNotNull,
        reason: '${entry.key}: missing $key (need title + body)',
      );
      expect(node!['title'], isA<String>(), reason: '${entry.key}: $key.title');
      expect(node['body'], isA<String>(), reason: '${entry.key}: $key.body');
      final stray = markersIn(node).difference(allowed);
      expect(
        stray,
        isEmpty,
        reason: '${entry.key}: $key uses unsent markers $stray '
            '(engine sends ${allowed.toList()..sort()})',
      );
    }
  }

  test('every emitted rule message_key has en/sl/de title+body with valid markers', () {
    for (final r in PlantTaskRulesSeed.rules) {
      checkKey(r.messageKey, ruleMarkers(r));
    }
  });

  test('generic R1/R2/R3/R6 keys exist with valid markers', () {
    generic.forEach(checkKey);
  });

  test('no suggestion value contains a literal \$ (slang would interpolate it)', () {
    void walk(dynamic node) {
      if (node is Map) {
        node.values.forEach(walk);
      } else if (node is String) {
        expect(node.contains(r'$'), isFalse, reason: 'stray \$ in "$node"');
      }
    }

    for (final sug in locales.values) {
      walk(sug);
    }
  });
}
