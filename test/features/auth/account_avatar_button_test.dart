import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/features/auth/presentation/widgets/account_avatar_button.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Guest: no client → null email. Signed-in: a fixed email overrides the getter
/// (a real session needs Supabase, which these widget tests must not touch).
class _GuestAuth extends AuthService {
  _GuestAuth() : super(null);
}

class _SignedInAuth extends AuthService {
  _SignedInAuth() : super(null);
  @override
  String? get email => 'jan@firma.si';
}

Future<void> _pump(WidgetTester tester, AuthService auth) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => auth),
          // Avoid Supabase.instance in the rebuild watch.
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: AccountAvatarButton())),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('guest shows the person-outline avatar; tap opens the sign-in sheet', (
    tester,
  ) async {
    await _pump(tester, _GuestAuth());

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text(t.account.guest_title), findsNothing);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text(t.account.guest_title), findsOneWidget);
    expect(find.text(t.account.sign_in_cta), findsOneWidget);
  });

  testWidgets('signed-in hides the indicator entirely', (tester) async {
    await _pump(tester, _SignedInAuth());

    // Nothing to flag once signed in → no avatar, no button.
    expect(find.byIcon(Icons.person_outline), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });
}
