import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/sync/connectivity.dart';
import 'package:tendask/features/auth/data/email_domain_checker.dart';
import 'package:tendask/features/auth/presentation/email_login_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Auth that never touches the network — sign-in send always "succeeds".
class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(null);
  @override
  Future<void> sendEmailOtp(String email) async {}
}

/// Domain checker wired to a fixed verdict (no DNS), to drive the gate.
EmailDomainChecker _checkerReturning(DomainVerdict verdict) {
  return EmailDomainChecker((name, type) async {
    switch (verdict) {
      case DomainVerdict.missing:
        return {'Status': 3};
      case DomainVerdict.exists:
        return {
          'Status': 0,
          'Answer': [
            {'type': 15},
          ],
        };
      case DomainVerdict.unknown:
        return null;
    }
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required DomainVerdict verdict,
  String? initialEmail,
}) async {
  // In-memory drift backs localPrefs (the screen persists a resume marker on a
  // successful send); addTearDown closes it after the test.
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => _FakeAuthService()),
          databaseProvider.overrideWithValue(db),
          emailDomainCheckerProvider.overrideWith(
            (ref) => _checkerReturning(verdict),
          ),
          // Deterministic "online" so the DNS gate runs (and no platform channel).
          onlineStatusProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: MaterialApp(home: EmailLoginScreen(initialEmail: initialEmail)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Lets the async send chain (DNS + OTP) resolve without firing the 1 s resend
/// timer (so pumpAndSettle's "pending timer" trap is avoided).
Future<void> _settleAsync(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('invalid format shows the email error, stays on email step', (
    tester,
  ) async {
    await _pumpScreen(tester, verdict: DomainVerdict.exists);
    await tester.enterText(find.byType(TextField), 'not-an-email');
    await tester.tap(find.text(t.email_login.send_code));
    await tester.pump();

    expect(find.text(t.email_login.err_email), findsOneWidget);
    expect(find.text(t.email_login.code_label), findsNothing);
  });

  testWidgets('domain typo surfaces a "did you mean" suggestion; tap applies it', (
    tester,
  ) async {
    await _pumpScreen(tester, verdict: DomainVerdict.exists);
    await tester.enterText(find.byType(TextField), 'jan@gmal.com');
    await tester.tap(find.text(t.email_login.send_code));
    await tester.pump();

    final suggested = t.email_login.did_you_mean(suggestion: 'jan@gmail.com');
    expect(find.text(suggested), findsOneWidget);
    // Still on the email step — the typo gate did not send.
    expect(find.text(t.email_login.code_label), findsNothing);

    await tester.tap(find.text(suggested));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'jan@gmail.com',
    );
  });

  testWidgets('a non-existent domain blocks before sending', (tester) async {
    await _pumpScreen(tester, verdict: DomainVerdict.missing);
    await tester.enterText(find.byType(TextField), 'jan@neobstaja-xyz.com');
    await tester.tap(find.text(t.email_login.send_code));
    await _settleAsync(tester);

    expect(find.text(t.email_login.err_email_domain), findsOneWidget);
    expect(find.text(t.email_login.code_label), findsNothing);
  });

  testWidgets('successful send advances to code step with a resend cooldown', (
    tester,
  ) async {
    await _pumpScreen(tester, verdict: DomainVerdict.exists);
    await tester.enterText(find.byType(TextField), 'jan@firma123.si');
    await tester.tap(find.text(t.email_login.send_code));
    await _settleAsync(tester);

    // Now on the code step…
    expect(find.text(t.email_login.code_label), findsOneWidget);
    // …with the resend button counting down (disabled), not the plain label.
    expect(find.text(t.email_login.resend_in(seconds: 60)), findsOneWidget);
    expect(find.text(t.email_login.resend), findsNothing);
  });

  testWidgets('code step uses a numeric keyboard', (tester) async {
    await _pumpScreen(tester, verdict: DomainVerdict.exists);
    await tester.enterText(find.byType(TextField), 'jan@firma123.si');
    await tester.tap(find.text(t.email_login.send_code));
    await _settleAsync(tester);

    final codeField = tester.widget<TextField>(find.byType(TextField));
    expect(codeField.keyboardType, TextInputType.number);
  });

  testWidgets('resumed with an initial email opens straight on the code step', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      verdict: DomainVerdict.exists,
      initialEmail: 'jan@firma123.si',
    );

    // Skipped the email step → already entering the code, with the address shown.
    expect(find.text(t.email_login.code_label), findsOneWidget);
    expect(find.text(t.email_login.email_label), findsNothing);
    expect(
      find.text(t.email_login.code_sent(email: 'jan@firma123.si')),
      findsOneWidget,
    );
    // A resumed screen has no back button, so it offers its own way out.
    expect(find.text(t.email_login.skip_for_now), findsOneWidget);
  });

  testWidgets('the email step never shows the resume escape hatch', (
    tester,
  ) async {
    await _pumpScreen(tester, verdict: DomainVerdict.exists);
    expect(find.text(t.email_login.skip_for_now), findsNothing);
  });
}
