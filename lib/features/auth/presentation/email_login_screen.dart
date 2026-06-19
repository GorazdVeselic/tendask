import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/config.dart';
import '../../../core/sync/connectivity.dart';
import '../../../core/sync/sync_coordinator.dart';
import '../../../i18n/translations.g.dart';
import '../data/email_domain_checker.dart';
import '../data/email_validation.dart';
import 'post_sign_in_navigation.dart';

enum _Step { email, code }

/// Email OTP sign-in (M7.3b). Two steps: enter email → enter the code. Creates
/// the account if new, else signs into the existing one. The guest's local rows
/// are then claimed to this account and synced (a merge — signing in keeps the
/// device's data, never resets it).
///
/// Input hardening (FR-11): format validation, a "did you mean" domain-typo
/// suggestion, a DNS-over-HTTPS existence check (fail-open, skipped offline),
/// and a resend cooldown mirroring the server-side throttle.
class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  _Step _step = _Step.email;
  bool _loading = false;
  String? _error;

  /// A pending domain-typo suggestion (full corrected address) shown under the
  /// field; tapping it applies the fix.
  String? _suggestion;

  /// The exact email the user re-confirmed despite a suggestion, so a second
  /// send goes through instead of looping on the same "did you mean?" hint.
  String? _confirmedEmail;

  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _applySuggestion(String suggestion) {
    _emailController.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    setState(() {
      _suggestion = null;
      _confirmedEmail = null;
      _error = null;
    });
  }

  void _startResendCooldown() {
    _cooldownTimer?.cancel();
    _cooldownRemaining = kOtpResendCooldown.inSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldownRemaining--);
      if (_cooldownRemaining <= 0) timer.cancel();
    });
  }

  /// Validates the entered email (format → typo gate → domain existence), then
  /// sends the first code. Used by the email step's primary button.
  Future<void> _sendCode() async {
    final t = context.t;
    final email = _emailController.text.trim();

    if (!isValidEmailFormat(email)) {
      setState(() {
        _error = t.email_login.err_email;
        _suggestion = suggestEmailFix(email);
      });
      return;
    }

    // Did-you-mean gate: surface a likely typo once; re-sending the same address
    // confirms the user meant it (an unusual but real domain is never blocked).
    final fix = suggestEmailFix(email);
    if (fix != null && _confirmedEmail != email) {
      setState(() {
        _suggestion = fix;
        _confirmedEmail = email;
        _error = null;
      });
      return;
    }

    // Domain existence (DoH). Skipped when we already know we're offline (the
    // garden case): the lookup would just burn the timeout before sendEmailOtp
    // fails anyway. Fail-open otherwise — only a definitive "missing" blocks.
    final domain = emailDomain(email);
    final knownOffline = ref.read(onlineStatusProvider).value == false;
    if (domain != null && !knownOffline) {
      setState(() {
        _loading = true;
        _error = null;
        _suggestion = null;
      });
      final verdict = await ref.read(emailDomainCheckerProvider).verify(domain);
      if (!mounted) return;
      if (verdict == DomainVerdict.missing) {
        setState(() {
          _loading = false;
          _error = t.email_login.err_email_domain;
        });
        return;
      }
    }
    await _dispatchOtp(email);
  }

  /// Sends/resends the OTP and (re)starts the cooldown. No validation or DNS
  /// gate — the address was already vetted by [_sendCode]; resend must never be
  /// blocked by a flaky later lookup once a code is already on its way.
  Future<void> _dispatchOtp(String email) async {
    final t = context.t;
    setState(() {
      _loading = true;
      _error = null;
      _suggestion = null;
    });
    try {
      await ref.read(authServiceProvider).sendEmailOtp(email);
      if (!mounted) return;
      _startResendCooldown();
      // Dismiss the email (QWERTY) keyboard before showing the code field, then
      // focus it next frame: switching steps in place keeps the keyboard open,
      // and Android won't re-query the input type, so it stays QWERTY for the
      // numeric code. Closing and reopening forces a fresh numeric keyboard.
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _step = _Step.code);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _codeFocus.requestFocus();
      });
    } on Object catch (e) {
      if (!mounted) return;
      // Show only a generic message: the raw exception can echo the address or
      // backend internals. Keep the detail in the log, not on screen.
      debugPrint('OTP send failed: $e');
      setState(() => _error = t.email_login.err_send);
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).verifyEmailOtp(email, code);
      if (!mounted) return;
      // Session established — start() claims the guest's local rows to this
      // account, pushes them, and pulls the account's existing data (merge).
      final syncFuture = ref.read(syncCoordinatorProvider.notifier).start();
      await goToLocationOrHome(context, ref, syncFuture: syncFuture);
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
    final canResend = !_loading && _cooldownRemaining <= 0;

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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
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
                if (_suggestion != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _applySuggestion(_suggestion!),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        t.email_login.did_you_mean(suggestion: _suggestion!),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  t.email_login.code_sent(email: _emailController.text.trim()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  focusNode: _codeFocus,
                  keyboardType: TextInputType.number,
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
                      : Text(
                          _step == _Step.email
                              ? t.email_login.send_code
                              : t.email_login.verify,
                        ),
                ),
              ),
              if (_step == _Step.code) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: canResend
                      ? () => _dispatchOtp(_emailController.text.trim())
                      : null,
                  child: Text(
                    _cooldownRemaining > 0
                        ? t.email_login.resend_in(seconds: _cooldownRemaining)
                        : t.email_login.resend,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
