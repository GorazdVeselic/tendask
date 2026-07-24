import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/tasks/data/recurrence.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/when_step.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  Future<void> pump(
    WidgetTester tester, {
    required TaskStatus status,
    required void Function(Recurrence? rule, bool valid) onSetRecurrence,
  }) => tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: WhenStepBody(
            date: DateTime(2026, 6, 2, 9),
            status: status,
            recurrence: null,
            onSetDate: (_) {},
            onSetStatus: (_) {},
            onSetRecurrence: onSetRecurrence,
          ),
        ),
      ),
    ),
  );

  testWidgets('recurrence picker is hidden for a done task', (tester) async {
    await pump(tester, status: TaskStatus.done, onSetRecurrence: (_, _) {});
    expect(find.text('Ponavljanje'), findsNothing);
  });

  testWidgets('waiting task: picking weekly emits a valid 7-day rule', (
    tester,
  ) async {
    Recurrence? captured;
    bool? lastValid;
    await pump(
      tester,
      status: TaskStatus.waiting,
      onSetRecurrence: (r, valid) {
        captured = r;
        lastValid = valid;
      },
    );

    expect(find.text('Ponavljanje'), findsOneWidget);
    await tester.tap(find.text('Tedensko'));
    await tester.pump();

    expect(captured, const Recurrence(everyDays: 7));
    expect(lastValid, isTrue);
    // The next-occurrence preview appears for a valid rule.
    expect(find.textContaining('Naslednje:'), findsOneWidget);
  });

  testWidgets('custom mode reveals the interval field', (tester) async {
    await pump(tester, status: TaskStatus.waiting, onSetRecurrence: (_, _) {});
    expect(find.text('Vsakih'), findsNothing);

    await tester.tap(find.text('Po meri'));
    await tester.pump();

    expect(find.text('Vsakih'), findsOneWidget);
  });

  testWidgets('clearing the custom interval keeps custom mode', (tester) async {
    // Parent rebuilds with each emitted rule, mirroring EntryScreen — this is
    // the condition under which a ValueKey on the picker would reset the mode.
    Recurrence? rec;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => WhenStepBody(
                date: DateTime(2026, 6, 2, 9),
                status: TaskStatus.waiting,
                recurrence: rec,
                onSetDate: (_) {},
                onSetStatus: (_) {},
                onSetRecurrence: (r, _) => setState(() => rec = r),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Po meri'));
    await tester.pump();
    expect(find.text('Vsakih'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('Vsakih'), findsOneWidget);
  });

  testWidgets('empty custom interval reports invalid', (tester) async {
    bool? lastValid;
    await pump(
      tester,
      status: TaskStatus.waiting,
      onSetRecurrence: (_, valid) => lastValid = valid,
    );

    await tester.tap(find.text('Po meri'));
    await tester.pump();
    expect(lastValid, isTrue); // default "14" is valid

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(lastValid, isFalse);
    expect(find.text('Vnesi število'), findsOneWidget);
  });

  testWidgets('a single repeat (1) is valid', (tester) async {
    Recurrence? captured;
    bool? lastValid;
    await pump(
      tester,
      status: TaskStatus.waiting,
      onSetRecurrence: (r, valid) {
        captured = r;
        lastValid = valid;
      },
    );

    await tester.tap(find.text('Dnevno'));
    await tester.pump();
    await tester.tap(find.text('Ponovi določeno število krat'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pump();

    expect(lastValid, isTrue);
    expect(captured, const Recurrence(everyDays: 1, remaining: 1));
  });

  testWidgets('empty total count reports invalid', (tester) async {
    bool? lastValid;
    await pump(
      tester,
      status: TaskStatus.waiting,
      onSetRecurrence: (_, valid) => lastValid = valid,
    );

    await tester.tap(find.text('Dnevno'));
    await tester.pump();
    await tester.tap(find.text('Ponovi določeno število krat'));
    await tester.pump();
    expect(lastValid, isTrue); // default "5" is valid

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(lastValid, isFalse);
    expect(find.text('Vnesi število'), findsOneWidget);
  });
}
