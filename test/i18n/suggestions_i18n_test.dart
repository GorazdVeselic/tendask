import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tool/seed/plant_task_rules_seed.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_text.dart';

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

  // Generic keys (R3/R2/R6) and their params from docs/m11/03. R1 is not here:
  // it never emits a card of its own, only the dry_window suffix (O4).
  final generic = {
    'suggestions.cadence.overdue': {
      'subject',
      'task',
      'days_overdue',
      'cadence_days',
    },
    'suggestions.history.anniversary': {'subject', 'task', 'last_year_date'},
    // No subject, and deliberately no {percent}: the engine sends the number as
    // evidence, but the free Home band must not print it — a share of the
    // neighbourhood is Plus content (skupnost-agregacija.md §12.5). The number
    // lives on /community/task, next to its sample size and season caveat.
    'suggestions.community.most_started': {'task'},
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

  test('an optional marker sits in a [clause], so its sentence survives', () {
    // frost_date only ships when the rule is frost-gated AND the climate has a
    // last-frost date; five bodies ended as "… ko mine pozeba — okoli ." (N20).
    for (final r in PlantTaskRulesSeed.rules) {
      final markers = ruleMarkers(r);
      if (!markers.contains('frost_date')) continue;
      for (final entry in locales.entries) {
        final body = entryFor(entry.value, r.messageKey)!['body'] as String;
        if (!body.contains('{frost_date}')) continue;
        final filled = fillTemplate(body, {
          for (final m in markers)
            if (m != 'frost_date') m: 'X',
        });
        expect(
          filled,
          isNot(anyOf(contains(' .'), contains('  '))),
          reason: '${entry.key}: ${r.messageKey} without frost_date → "$filled"',
        );
      }
    }
  });

  test('R1 has no card of its own, only the dry-window suffix', () {
    for (final entry in locales.entries) {
      // suggestions.weather.window_open was never emitted by the engine (O4).
      expect(
        entry.value['weather'],
        isNull,
        reason: '${entry.key}: R1 emits no card — the key is dead',
      );
      final suffix = entry.value['dry_window'];
      expect(suffix, isA<String>(), reason: '${entry.key}: dry_window missing');
      final markers = markerRe
          .allMatches(suffix as String)
          .map((m) => m.group(1)!)
          .toSet();
      expect(
        markers,
        {'dry_hours'},
        reason: '${entry.key}: dry_window uses unsent markers $markers',
      );
    }
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
