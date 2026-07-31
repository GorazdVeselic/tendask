import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_phase_icon.dart';

const _boundaryKey = Key('moon-boundary');

Future<ui.Image> _render(
  WidgetTester tester,
  MoonPhase phase,
  double illumFraction,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: _boundaryKey,
          child: ColoredBox(
            color: Colors.white,
            child: MoonPhaseIcon(
              phase: phase,
              illumFraction: illumFraction,
              size: 64,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  );
  final image = await tester.runAsync(
    () => captureImage(tester.element(find.byKey(_boundaryKey))),
  );
  // captureImage ran inside runAsync, so the future has already completed.
  return image!;
}

/// True when the pixel at fractional position (fx, fy) is filled (dark ink).
Future<bool> _filledAt(WidgetTester tester, ui.Image image, double fx, double fy) async {
  final data = await tester.runAsync(() => image.toByteData());
  final x = (image.width * fx).round();
  final y = (image.height * fy).round();
  final red = data!.getUint8((y * image.width + x) * 4);
  return red < 128;
}

void main() {
  testWidgets('renders all eight phases without errors', (tester) async {
    for (final phase in MoonPhase.values) {
      for (final f in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await _render(tester, phase, f);
        expect(tester.takeException(), isNull, reason: '$phase @ $f');
      }
    }
  });

  testWidgets('respects requested size', (tester) async {
    await _render(tester, MoonPhase.firstQuarter, 0.5);
    expect(tester.getSize(find.byType(MoonPhaseIcon)), const Size(64, 64));
  });

  testWidgets('new moon leaves the disc unfilled', (tester) async {
    final image = await _render(tester, MoonPhase.newMoon, 0.0);
    expect(await _filledAt(tester, image, 0.5, 0.5), isFalse);
  });

  testWidgets('full moon fills the whole disc', (tester) async {
    final image = await _render(tester, MoonPhase.fullMoon, 1.0);
    expect(await _filledAt(tester, image, 0.25, 0.5), isTrue);
    expect(await _filledAt(tester, image, 0.75, 0.5), isTrue);
  });

  testWidgets('waxing crescent is lit on the right only', (tester) async {
    final image = await _render(tester, MoonPhase.waxingCrescent, 0.25);
    expect(await _filledAt(tester, image, 0.85, 0.5), isTrue);
    expect(await _filledAt(tester, image, 0.5, 0.5), isFalse);
    expect(await _filledAt(tester, image, 0.15, 0.5), isFalse);
  });

  testWidgets('waning crescent mirrors the waxing shape', (tester) async {
    final image = await _render(tester, MoonPhase.waningCrescent, 0.25);
    expect(await _filledAt(tester, image, 0.15, 0.5), isTrue);
    expect(await _filledAt(tester, image, 0.5, 0.5), isFalse);
    expect(await _filledAt(tester, image, 0.85, 0.5), isFalse);
  });

  testWidgets('quarters split the disc down the middle', (tester) async {
    final first = await _render(tester, MoonPhase.firstQuarter, 0.5);
    expect(await _filledAt(tester, first, 0.75, 0.5), isTrue);
    expect(await _filledAt(tester, first, 0.25, 0.5), isFalse);

    final last = await _render(tester, MoonPhase.lastQuarter, 0.5);
    expect(await _filledAt(tester, last, 0.25, 0.5), isTrue);
    expect(await _filledAt(tester, last, 0.75, 0.5), isFalse);
  });

  testWidgets('out-of-range fraction is clamped, not thrown', (tester) async {
    final image = await _render(tester, MoonPhase.fullMoon, 1.2);
    expect(tester.takeException(), isNull);
    expect(await _filledAt(tester, image, 0.5, 0.5), isTrue);
  });
}
