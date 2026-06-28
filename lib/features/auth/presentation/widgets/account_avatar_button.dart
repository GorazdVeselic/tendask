import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../i18n/translations.g.dart';

/// AppBar affordance that flags guest state on Home: a person outline with a
/// honey dot (tap → a calm sign-in sheet). Shown ONLY for guests — once signed
/// in there is nothing to flag, so it disappears (account lives in settings).
/// Never an alarm: guest is a legitimate offline-first mode, so the cue is quiet.
class AccountAvatarButton extends ConsumerWidget {
  const AccountAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild on sign-in/out so the indicator appears/disappears with the session.
    ref.watch(authStateChangesProvider);
    final email = ref.read(authServiceProvider).email;
    final cs = Theme.of(context).colorScheme;
    final t = context.t;

    // Signed in → no indicator needed.
    if (email != null && email.isNotEmpty) return const SizedBox.shrink();

    return IconButton(
      tooltip: t.account.guest_tooltip,
      onPressed: () => showAccountSheet(context),
      icon: Badge(
        backgroundColor: AppColors.honey,
        smallSize: 9,
        child: CircleAvatar(
          radius: 14,
          backgroundColor: cs.surfaceContainerHighest,
          child: Icon(
            Icons.person_outline,
            size: 19,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Calm guest sheet: explains that data is local-only and offers sign-in (which
/// keeps the device's data). Only shown for guests — signing in is optional.
Future<void> showAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    // Root navigator so the sheet covers the shell's FAB + bottom nav (they
    // live above the home branch navigator, else the FAB '+' overlaps the text).
    useRootNavigator: true,
    builder: (_) => const _AccountSheet(),
  );
}

class _AccountSheet extends StatelessWidget {
  const _AccountSheet();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 8),
            Text(
              t.account.guest_title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.account.guest_body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () {
                  // Capture the router before popping — the sheet's context is
                  // defunct for navigation once it is dismissed.
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push('/login');
                },
                child: Text(t.account.sign_in_cta),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.account.maybe_later),
            ),
          ],
        ),
      ),
    );
  }
}
