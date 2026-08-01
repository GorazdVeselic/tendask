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
  // The visibility rules the four T4 entry points share. Their gate widgets
  // cannot exercise this layer while kMoonCalendarEnabled is false, so these
  // cases are what pins the behaviour that goes live at ignition (T7).
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

  group('journalMoonLayerOn', () {
    test('needs both the master switch and the journal sub-switch', () {
      expect(journalMoonLayerOn(_settings()), isTrue);
      expect(journalMoonLayerOn(_settings(showInJournal: false)), isFalse);
      expect(journalMoonLayerOn(_settings(enabled: false)), isFalse);
      expect(
        journalMoonLayerOn(_settings(enabled: false, showInJournal: true)),
        isFalse,
      );
    });

    test('treats a failed settings load as off', () {
      expect(journalMoonLayerOn(null), isFalse);
    });
  });
}
