import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/config.dart';
import '../../../i18n/translations.g.dart';

/// Brief branded splash (zaslon 00) shown over the native splash, then routes to
/// [next] (home / onboarding / a cold-start deep-link). Android 12+ system splash
/// can only show a centered icon, so the wordmark + version live here instead.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});

  /// Where to go once the splash has shown for [kSplashMinDuration].
  final String next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String? _version;
  late final AnimationController _dotsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void initState() {
    super.initState();
    unawaited(_loadVersion());
    Timer(kSplashMinDuration, () {
      if (mounted) context.go(widget.next);
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
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
                        _version == null ? '' : 'v$_version',
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

/// Decorative H3 hexagon grid behind the brand (wireframe 00-splash), faint white
/// outlines tiled over the green gradient.
class _HexGridPainter extends CustomPainter {
  const _HexGridPainter();

  static const double _tileW = 56;
  static const double _tileH = 64;
  static const double _scale = 1.3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.10);

    final hex = Path()
      ..moveTo(28, 1)
      ..lineTo(55, 16)
      ..lineTo(55, 48)
      ..lineTo(28, 63)
      ..lineTo(1, 48)
      ..lineTo(1, 16)
      ..close();

    canvas.save();
    canvas.scale(_scale);
    final w = size.width / _scale;
    final h = size.height / _scale;
    for (double y = 0; y < h; y += _tileH) {
      for (double x = 0; x < w; x += _tileW) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawPath(hex, paint);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HexGridPainter oldDelegate) => false;
}
