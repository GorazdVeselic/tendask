import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/sync/sync_coordinator.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../i18n/translations.g.dart';

enum _Step { email, code }

/// Email OTP (M7.3b). Two steps: enter email → enter the code. Two modes:
/// - link ([widget.link] true): upgrade the anonymous session in place
///   (updateUser) → keeps local data → home.
/// - sign-in (false): sign into a new/existing account (signInWithOtp) → clear
///   the previous session's local rows, pull this account's data → location.
class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key, this.link = false});

  /// True = link email to the current anonymous account (keep data); false =
  /// sign in to an email account (switch account).
  final bool link;

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  _Step _step = _Step.email;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String s) =>
      s.contains('@') && s.contains('.') && !s.endsWith('.');

  Future<void> _sendCode() async {
    final t = context.t;
    final email = _emailController.text.trim();
    if (!_looksLikeEmail(email)) {
      setState(() => _error = t.email_login.err_email);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await (widget.link ? auth.sendLinkOtp(email) : auth.sendSignInOtp(email));
      if (!mounted) return;
      setState(() => _step = _Step.code);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = '${t.email_login.err_send}\n${e.message}');
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = '${t.email_login.err_send}\n$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    final t = context.t;
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    // OTP length is a server setting (6–8+); don't hard-code it, just sanity-check.
    if (code.length < 6) {
      setState(() => _error = t.email_login.err_code);
      return;
    }
    // Sign-in switches accounts and drops this device's current data. Warn first
    // when there is local content — the keep-data path is "Link account".
    if (!widget.link) {
      final hasData = await ref.read(databaseProvider).hasUserData();
      if (!mounted) return;
      if (hasData) {
        final ok = await showConfirmDialog(
          context,
          title: t.email_login.switch_warn_title,
          body: t.email_login.switch_warn_body,
          confirmLabel: t.email_login.switch_warn_confirm,
          cancelLabel: t.email_login.switch_warn_cancel,
        );
        if (!ok || !mounted) return;
      }
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      if (widget.link) {
        await auth.verifyLinkOtp(email, code);
        if (!mounted) return;
        // Same uid — keep local data; sync pushes it to the cloud.
        ref.read(syncCoordinatorProvider.notifier).start();
        context.go('/home');
      } else {
        // Back up the current account's pending rows before leaving it
        // (recoverable if it had an email; harmless for a guest). Best-effort:
        // verifySignInOtp below needs the network anyway.
        await ref.read(syncServiceProvider).flushPush();
        await auth.verifySignInOtp(email, code);
        // Switched account — drop the previous session's rows, keep onboarding
        // flag, then pull this account's data.
        await ref.read(databaseProvider).clearUserData(keepFlags: true);
        if (!mounted) return;
        ref.read(syncCoordinatorProvider.notifier).start();
        context.go('/location');
      }
    } on Object {
      if (!mounted) return;
      setState(() => _error = t.email_login.err_verify);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.email_login.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == _Step.email) ...[
                Text(
                  t.email_login.intro,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: t.email_login.email_label,
                    hintText: t.email_login.email_hint,
                  ),
                  onSubmitted: (_) => _loading ? null : _sendCode(),
                ),
              ] else ...[
                Text(
                  t.email_login.code_sent(email: _emailController.text.trim()),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: t.email_login.code_label,
                    hintText: t.email_login.code_hint,
                    counterText: '',
                  ),
                  onSubmitted: (_) => _loading ? null : _verify(),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _loading
                      ? null
                      : (_step == _Step.email ? _sendCode : _verify),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(_step == _Step.email
                          ? t.email_login.send_code
                          : t.email_login.verify),
                ),
              ),
              if (_step == _Step.code) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: _loading ? null : _sendCode,
                  child: Text(t.email_login.resend),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
