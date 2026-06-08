import 'package:flutter/material.dart';

/// Shows a brief, auto-dismissing toast at the TOP of the screen. [error] tints
/// it red (via the error container) so warnings read clearly — the default
/// bottom SnackBar is easy to miss on a dark theme.
void showTopToast(BuildContext context, String message, {bool error = false}) {
  final overlay = Overlay.of(context);
  final cs = Theme.of(context).colorScheme;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _TopToast(
            message: message,
            background: error ? cs.errorContainer : cs.inverseSurface,
            foreground: error ? cs.onErrorContainer : cs.onInverseSurface,
            onDone: () => entry.remove(),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  const _TopToast({
    required this.message,
    required this.background,
    required this.foreground,
    required this.onDone,
  });

  final String message;
  final Color background;
  final Color foreground;
  final VoidCallback onDone;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _c.forward();
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await _c.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(fade),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: widget.background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: widget.foreground),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: widget.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
