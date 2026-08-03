import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/features/plus/application/plus_provider.dart';
import 'package:tendask/features/plus/application/plus_token.dart';
import 'package:tendask/features/plus/presentation/tendask_plus_screen.dart';
import 'package:tendask/features/plus/presentation/widgets/plus_settings_card.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Mini-router: the real route is flag-guarded, so the tests drive the widgets
/// directly and only need somewhere for a tap to land.
GoRouter _router(Widget home) => GoRouter(
  initialLocation: '/here',
  routes: [
    GoRoute(path: '/here', builder: (_, _) => home),
    GoRoute(
      path: '/moon-settings',
      name: 'moon-settings',
      builder: (_, _) => const Scaffold(body: Text('MOON-SETTINGS')),
    ),
    GoRoute(
      path: '/tendask-plus',
      name: 'tendask-plus',
      builder: (_, _) => const Scaffold(body: Text('TENDASK-PLUS')),
    ),
  ],
);

Future<void> _pump(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp.router(
        routerConfig: _router(home),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final granted = PlusStatus.active(
    until: DateTime.utc(2026, 9, 2, 10, 19),
    kind: 'granted',
  );

  testWidgets('an active entitlement shows how long it runs', (tester) async {
    await _pump(tester, Scaffold(body: PlusScreenBody(status: granted)));

    expect(
      find.text(t.plus.active_until(date: '2. 9. 2026')),
      findsOneWidget,
    );
    expect(find.text(t.plus.inactive), findsNothing);
  });

  testWidgets('a lifetime grant shows no end date', (tester) async {
    await _pump(
      tester,
      Scaffold(
        body: PlusScreenBody(
          status: PlusStatus.active(
            until: DateTime.utc(2027, 8, 12),
            kind: kPlusKindLifetime,
          ),
        ),
      ),
    );

    expect(find.text(t.plus.active_lifetime), findsOneWidget);
    expect(find.textContaining('2027'), findsNothing);
  });

  // The point of this screen (plan T6 step 5): it is the way back into the moon
  // settings that does not depend on the moon switch itself.
  testWidgets('the moon row opens the moon settings', (tester) async {
    await _pump(tester, Scaffold(body: PlusScreenBody(status: granted)));

    await tester.tap(find.text(t.plus.moon));
    await tester.pumpAndSettle();

    expect(find.text('MOON-SETTINGS'), findsOneWidget);
  });

  testWidgets('without Plus the moon row is a description, not a way in', (
    tester,
  ) async {
    await _pump(
      tester,
      const Scaffold(body: PlusScreenBody(status: PlusStatus.none())),
    );

    expect(find.text(t.plus.inactive), findsOneWidget);
    expect(find.text(t.plus.tagline), findsOneWidget);

    await tester.tap(find.text(t.plus.moon));
    await tester.pumpAndSettle();

    expect(find.text('MOON-SETTINGS'), findsNothing);
    expect(find.text(t.plus.moon), findsOneWidget);
  });

  testWidgets('the screen reads the entitlement from plusProvider', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plusProvider.overrideWith((ref) => Stream.value(granted)),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(
            routerConfig: _router(const TendaskPlusScreen()),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.plus.active_until(date: '2. 9. 2026')), findsOneWidget);
  });

  testWidgets('the Settings card stays dark behind the flag', (tester) async {
    await _pump(tester, const Scaffold(body: PlusSettingsCard()));

    expect(
      find.byType(PlusEntryCard),
      kTendaskPlusEnabled ? findsOneWidget : findsNothing,
    );
  });

  testWidgets('the Settings card opens the Tendask+ screen', (tester) async {
    await _pump(tester, const Scaffold(body: PlusEntryCard()));

    await tester.tap(find.text('Tendask+'));
    await tester.pumpAndSettle();

    expect(find.text('TENDASK-PLUS'), findsOneWidget);
  });
}
