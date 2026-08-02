import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/biodynamic/biodynamic_day.dart';

/// Canonical illuminated fraction for a principal-phase marker — the event
/// glyph should be a crisp new/quarter/full disc, not the midday sample.
double principalIllumFraction(MoonPhase phase) => switch (phase) {
      MoonPhase.newMoon => 0.0,
      MoonPhase.firstQuarter || MoonPhase.lastQuarter => 0.5,
      _ => 1.0,
    };

/// Monochrome moon-phase glyph drawn from the illuminated fraction (spec
/// §11.7): a faint limb outline plus the lit region bounded by the terminator
/// ellipse. Shared by the calendar grid, the home chip and the day sheet.
class MoonPhaseIcon extends StatelessWidget {
  const MoonPhaseIcon({
    super.key,
    required this.phase,
    required this.illumFraction,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  final MoonPhase phase;

  /// Illuminated fraction of the disc, 0 (new) .. 1 (full).
  final double illumFraction;

  final double size;

  /// Overrides the default theme colour ([ColorScheme.onSurfaceVariant]).
  final Color? color;

  /// Spoken name of the phase, for surfaces where the glyph is the only carrier
  /// (the month grid). Where the phase is already written out next to it (week
  /// agenda, legend, sheet) leave it null — a screen reader would repeat it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel;
    if (label != null) {
      return Semantics(
        label: label,
        child: ExcludeSemantics(child: _paint(context)),
      );
    }
    return _paint(context);
  }

  Widget _paint(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MoonPhasePainter(
        illumFraction: illumFraction.clamp(0.0, 1.0),
        waxing: isWaxing(phase),
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MoonPhasePainter extends CustomPainter {
  const _MoonPhasePainter({
    required this.illumFraction,
    required this.waxing,
    required this.color,
  });

  final double illumFraction;
  final bool waxing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    final strokeWidth = math.max(1.0, radius * 0.10);
    final disc = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    canvas.drawOval(
      disc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color.withValues(alpha: 0.4),
    );

    if (illumFraction < 0.005) return;
    final fill = Paint()..color = color;
    if (illumFraction > 0.995) {
      canvas.drawOval(disc, fill);
      return;
    }

    // Waning is the waxing shape mirrored across the vertical axis (northern
    // hemisphere convention: waxing Moon is lit on the right).
    canvas.save();
    if (!waxing) {
      canvas.translate(center.dx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-center.dx, 0);
    }

    // Lit limb: half circle top -> right -> bottom.
    final lit = Path()..addArc(disc, -math.pi / 2, math.pi);
    // Signed terminator half-width: -1 (new) .. 0 (quarter) .. 1 (full).
    final k = 2 * illumFraction - 1;
    if (k.abs() < 0.01) {
      lit.lineTo(center.dx, disc.top);
    } else {
      // Terminator ellipse arc bottom -> top, bulging toward the dark side
      // when gibbous (k > 0) and toward the lit limb when crescent (k < 0).
      lit.arcTo(
        Rect.fromCenter(
          center: center,
          width: disc.width * k.abs(),
          height: disc.height,
        ),
        math.pi / 2,
        k >= 0 ? math.pi : -math.pi,
        false,
      );
    }
    lit.close();
    canvas.drawPath(lit, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoonPhasePainter oldDelegate) =>
      oldDelegate.illumFraction != illumFraction ||
      oldDelegate.waxing != waxing ||
      oldDelegate.color != color;
}
