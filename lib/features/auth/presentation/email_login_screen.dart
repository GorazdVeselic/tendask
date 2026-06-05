import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../i18n/translations.g.dart';

enum _Step { email, code }

/// Email OTP sign-in (M7.3b). Two steps: enter email → enter the 6-digit code.
/// Upgrades the anonymous session in place (AuthService.sendEmailOtp), so the
/// local data is kept; on success the user has a permanent email account.
class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

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
      await ref.read(authServiceProvider).sendEmailOtp(email);
      if (!mounted) return;
      setState(() => _step = _Step.code);
    } on Object {
      if (!mounted) return;
      setState(() => _error = t.email_login.err_send);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    final t = context.t;
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = t.email_login.err_code);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).verifyEmailOtp(email, code);
      if (!mounted) return;
      // Location (16) is inserted before home in M7.3c; for now go to home.
      context.go('/home');
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
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: t.email_login.code_label,
                    hintText: t.email_login.code_hint,
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
