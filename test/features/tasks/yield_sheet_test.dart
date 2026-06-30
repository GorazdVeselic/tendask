import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/presentation/yield_sheet.dart';
import 'package:tendask/features/tasks/yield_unit.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  // Pumps a screen whose button opens the yield sheet, recording the resolved
  // result in [out] so each test can drive Save/Skip/Remove and assert it.
  Future<void> openSheet(
    WidgetTester tester,
    List<YieldSheetResult?> out, {
    YieldDraft? initial,
    bool allowSkip = false,
    bool allowRemove = false,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async => out.add(
                  await showYieldSheet(
                    context,
                    initial: initial,
                    allowSkip: allowSkip,
                    allowRemove: allowRemove,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('amount + unit + Save → YieldSaved', (tester) async {
    final out = <YieldSheetResult?>[];
    await openSheet(tester, out);

    await tester.enterText(find.byType(TextField), '2,5');
    await tester.pump();
    await tester.tap(find.text('kom')); // pieces
    await tester.pump();
    await tester.tap(find.text('Shrani'));
    await tester.pumpAndSettle();

    expect(out, hasLength(1));
    final result = out.single;
    expect(result, isA<YieldSaved>());
    final draft = (result! as YieldSaved).draft;
    expect(draft.amount, 2.5);
    expect(draft.unit, YieldUnit.pieces);
  });

  testWidgets('Save is disabled until a positive amount is entered', (
    tester,
  ) async {
    final out = <YieldSheetResult?>[];
    await openSheet(tester, out);

    FilledButton saveButton() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Shrani'));
    expect(saveButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(saveButton().onPressed, isNull); // zero is not a yield

    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();
    expect(saveButton().onPressed, isNotNull);
  });

  testWidgets('a double-tap on Save pops only the sheet, not the screen behind',
      (tester) async {
    final out = <YieldSheetResult?>[];
    await openSheet(tester, out);

    await tester.enterText(find.byType(TextField), '2');
    await tester.pump();
    // Two taps before the dismiss animation settles — the second must be a
    // no-op (without the guard it would pop the underlying screen).
    await tester.tap(find.text('Shrani'));
    await tester.tap(find.text('Shrani'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(out, hasLength(1));
    expect(out.single, isA<YieldSaved>());
    // The screen behind the sheet survived (its button is still mounted).
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('Skip → null (still completes without yield)', (tester) async {
    final out = <YieldSheetResult?>[];
    await openSheet(tester, out, allowSkip: true);

    await tester.tap(find.text('Preskoči'));
    await tester.pumpAndSettle();

    expect(out, [isNull]);
  });

  testWidgets('Remove on an existing yield → YieldCleared', (tester) async {
    final out = <YieldSheetResult?>[];
    await openSheet(
      tester,
      out,
      initial: const YieldDraft(amount: 4, unit: YieldUnit.kg),
      allowRemove: true,
    );

    await tester.tap(find.text('Odstrani pridelek'));
    await tester.pumpAndSettle();

    expect(out, [isA<YieldCleared>()]);
  });
}
