import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/sync/sync_coordinator.dart';
import '../../../i18n/translations.g.dart';

/// Sign-in / onboarding choice (wireframe 13): Apple (iOS only — M10), Google
/// and email, or continue as a guest. Signing in keeps the guest's local data
/// (claimed to the account on sign-in) — there is no separate "link" mode.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _googleLoading = false;

  void _comingSoon() {
    final t = context.t;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t.auth.coming_soon)));
  }

  void _continueAsGuest() {
    // Guest stays local (no cloud session) — straight to the location step.
    context.go('/location');
  }

  Future<void> _signInWithGoogle() async {
    final t = context.t;
    setState(() => _googleLoading = true);
    try {
      final signedIn = await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      if (!signedIn) return; // user dismissed the picker
      // start() claims the guest's local rows to this account, pushes them, and
      // pulls the account's existing data (a merge — sign-in keeps data).
      ref.read(syncCoordinatorProvider.notifier).start();
      context.go('/location');
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.auth.google_error)));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final busy = _googleLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(Icons.eco_outlined, size: 40, color: cs.primary),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.auth.title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        t.auth.value_prop,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              if (Platform.isIOS) ...[
                _DarkButton(
                  icon: Icons.apple,
                  label: t.auth.continue_apple,
                  onPressed: busy ? null : _comingSoon,
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: busy ? null : _signInWithGoogle,
                  child: _googleLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(t.auth.continue_google),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: busy ? null : () => context.push('/login-email'),
                  icon: const Icon(Icons.mail_outline, size: 20),
                  label: Text(t.auth.continue_email),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: busy ? null : _continueAsGuest,
                child: Text(
                  t.auth.guest,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.auth.guest_warning,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                t.auth.legal,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
      ),
    );
  }
}
