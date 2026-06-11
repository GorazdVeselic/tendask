import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/app_info.dart';
import '../../../core/config.dart';
import '../../../i18n/translations.g.dart';

/// Brief branded splash (zaslon 00) shown over the native splash, then routes to
/// [next] (home / onboarding / a cold-start deep-link). Android 12+ system splash
/// can only show a centered icon, so the wordmark + version live here instead.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, required this.next});

  /// Where to go once the splash has shown for [kSplashMinDuration].
  final String next;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Timer(kSplashMinDuration, () {
      if (mounted) context.go(widget.next);
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.3,
            colors: [AppColors.green400, AppColors.green, AppColors.green900],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _HexGridPainter()),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/splash/splash-logo.png', width: 116),
                  const SizedBox(height: 24),
                  const Text(
                    'Tendask',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.splash.tagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoadingDots(controller: _dotsController),
                      const SizedBox(height: 24),
                      Text(
                        switch (ref.watch(packageInfoProvider).asData?.value) {
                          final info? => 'v${info.version}',
                          null => '',
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three staggered fading dots as a calm loading indicator.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (controller.value - i * 0.2) % 1.0;
            final pulse = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.4 + 0.5 * pulse),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Decorative H3 honeycomb behind the brand (wireframe 00-splash): faint white
/// pointy-top hexagons tiled edge-to-edge over the green gradient.
class _HexGridPainter extends CustomPainter {
  const _HexGridPainter();

  static const double _r =
      42; // circumradius (center → pointy top/bottom vertex)
  static const double _w = _r * 1.7320508; // flat-to-flat width = √3·r
  static const double _rowStep =
      _r * 1.5; // pointy-top rows interlock at ¾ height

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.10);

    // One pointy-top hexagon centered at the origin; placed by translation.
    final hex = Path()
      ..moveTo(0, -_r)
      ..lineTo(_w / 2, -_r / 2)
      ..lineTo(_w / 2, _r / 2)
      ..lineTo(0, _r)
      ..lineTo(-_w / 2, _r / 2)
      ..lineTo(-_w / 2, -_r / 2)
      ..close();

    var row = 0;
    for (double cy = -_rowStep; cy - _r < size.height; cy += _rowStep, row++) {
      // Every other row shifts half a hex so the columns interlock.
      final startX = (row.isOdd ? _w / 2 : 0.0) - _w;
      for (double cx = startX; cx - _w / 2 < size.width; cx += _w) {
        canvas.save();
        canvas.translate(cx, cy);
        canvas.drawPath(hex, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_HexGridPainter oldDelegate) => false;
}
