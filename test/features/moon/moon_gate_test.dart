import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/features/moon/application/moon_settings_controller.dart';
import 'package:tendask/features/moon/presentation/moon_gate.dart';

MoonSettings _settings({bool enabled = true, bool showInJournal = true}) =>
    MoonSettings(
      enabled: enabled,
      system: CalendarSystem.sidereal,
      highlightGarden: true,
      showInJournal: showInJournal,
      showAstroDetails: true,
    );

void main() {
  // The visibility rules the entry points share. Their gate widgets cannot
  // exercise this layer while kMoonCalendarEnabled is false, so these cases are
  // what pins the behaviour that goes live at ignition (T7).
  group('moonSurfaceOn', () {
    test('follows the master switch', () {
      expect(moonSurfaceOn(_settings()), isTrue);
      expect(moonSurfaceOn(_settings(enabled: false)), isFalse);
    });

    test('treats a failed settings load as off', () {
      expect(moonSurfaceOn(null), isFalse);
    });

    test('ignores the journal sub-switch', () {
      // The 🌙 entry button follows the master switch alone (board C).
      expect(moonSurfaceOn(_settings(showInJournal: false)), isTrue);
    });
  });

  group('moonPlusSurfaceOn', () {
    test('needs the entitlement on top of the master switch', () {
      expect(moonPlusSurfaceOn(_settings(), true), isTrue);
      expect(moonPlusSurfaceOn(_settings(), false), isFalse);
      expect(moonPlusSurfaceOn(_settings(enabled: false), true), isFalse);
    });

    test('treats a failed settings load as off', () {
      expect(moonPlusSurfaceOn(null, true), isFalse);
    });

    test('the free phase does not follow it', () {
      // The Home chip keeps its phase without a licence (spec §6.5); only its
      // element-day CTA is swapped for the lock.
      expect(moonSurfaceOn(_settings()), isTrue);
      expect(moonPlusSurfaceOn(_settings(), false), isFalse);
    });
  });

  group('journalMoonLayerOn', () {
    test('needs the entitlement, the master switch and the sub-switch', () {
      expect(journalMoonLayerOn(_settings(), true), isTrue);
      expect(journalMoonLayerOn(_settings(), false), isFalse);
      expect(journalMoonLayerOn(_settings(showInJournal: false), true), isFalse);
      expect(journalMoonLayerOn(_settings(enabled: false), true), isFalse);
    });

    test('treats a failed settings load as off', () {
      expect(journalMoonLayerOn(null, true), isFalse);
    });
  });

  group('plantMoonChipTarget', () {
    String? target({
      MoonSettings? settings,
      bool isPlus = true,
      String? category = 'vegetable',
      String? plantId = 'tomato',
    }) => plantMoonChipTarget(
      settings ?? _settings(),
      isPlus: isPlus,
      category: category,
      plantId: plantId,
    );

    test('a plant the calendar knows returns its catalog id', () {
      expect(target(), 'tomato');
      // A category default, not just the per-plant override table.
      expect(target(category: 'fruit_tree', plantId: 'apple'), 'apple');
    });

    test('follows the switches like every other surface', () {
      expect(target(settings: _settings(enabled: false)), isNull);
      expect(
        plantMoonChipTarget(
          null,
          isPlus: true,
          category: 'vegetable',
          plantId: 'tomato',
        ),
        isNull,
      );
      // The journal sub-switch governs the colour layer, never this chip.
      expect(target(settings: _settings(showInJournal: false)), 'tomato');
    });

    test('the finder is paid, so no entitlement means no chip', () {
      expect(target(isPlus: false), isNull);
    });

    test('a private plant has nothing to prefill the finder with', () {
      expect(target(category: null, plantId: null), isNull);
      expect(target(category: 'vegetable', plantId: null), isNull);
    });

    test('plants outside the sowing calendar get no chip', () {
      // Houseplants, conifers and hedges (decision 2026-07-31/08-01): the
      // finder would only answer "no recommendation".
      expect(target(category: 'houseplant', plantId: 'monstera'), isNull);
      expect(target(category: 'conifer', plantId: 'spruce'), isNull);
      expect(target(category: 'hedge', plantId: 'privet'), isNull);
      // A vegetable missing from the override table resolves to no element.
      expect(target(category: 'vegetable', plantId: 'not-in-catalog'), isNull);
    });
  });
}
