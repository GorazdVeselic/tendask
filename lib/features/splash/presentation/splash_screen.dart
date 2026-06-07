import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/config.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  String? _version;

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
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
            if (_version != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Text(
                  'v$_version',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
