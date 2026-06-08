import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/local_prefs/local_prefs.dart';
import '../../../i18n/translations.g.dart';

/// First-run intro (wireframes 15/15b/15c/15d). Shown only until the user passes
/// it once (onboarding_seen flag); "Skip"/"Get started" both mark it seen.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localPrefsProvider).setOnboardingSeen();
    if (!mounted) return;
    context.go('/login');
  }

  void _next(int last) {
    if (_page >= last) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final slides = <_Slide>[
      _Slide(
        Icons.eco_outlined,
        t.onboarding.welcome_title,
        t.onboarding.welcome_body,
      ),
      _Slide(
        Icons.fact_check_outlined,
        t.onboarding.log_title,
        t.onboarding.log_body,
      ),
      _Slide(
        Icons.wb_cloudy_outlined,
        t.onboarding.remind_title,
        t.onboarding.remind_body,
      ),
      _Slide(
        Icons.public,
        t.onboarding.nearby_title,
        t.onboarding.nearby_body,
        badge: t.onboarding.soon_badge,
      ),
    ];
    final last = slides.length - 1;
    final isLast = _page == last;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 30),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: isLast
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: _finish,
                          child: Text(t.onboarding.skip),
                        ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) =>
                      _OnboardingPage(slide: slides[i]),
                ),
              ),
              _Dots(count: slides.length, active: _page),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => _next(last),
                  child: Text(isLast ? t.onboarding.start : t.onboarding.next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 144,
          height: 144,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Icon(slide.icon, size: 72, color: cs.primary),
        ),
        const SizedBox(height: 28),
        Text(
          slide.title,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          slide.body,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (slide.badge != null) ...[
          const SizedBox(height: 18),
          _Badge(label: slide.badge!),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: i == active ? 22 : 8,
            decoration: BoxDecoration(
              color: i == active ? cs.primary : cs.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _Slide {
  const _Slide(this.icon, this.title, this.body, {this.badge});

  final IconData icon;
  final String title;
  final String body;
  final String? badge;
}
