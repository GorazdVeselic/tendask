import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/widgets/confirm_dialog.dart';

/// The destructive haptic lives in `showConfirmDialog` (single point for every
/// delete/clear), gated on `destructive && confirmed`. These guard that gate.
void main() {
  late List<Object?> vibrations;
  late List<bool> outcomes;

  // Pumps a screen whose button opens the dialog; records each resolved result
  // in [outcomes] so the test can drive Yes/No by pumping (no future flattening).
  Future<void> openDialog(WidgetTester tester, {required bool destructive}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                outcomes.add(
                  await showConfirmDialog(
                    context,
                    title: 'Title',
                    body: 'Body',
                    confirmLabel: 'Yes',
                    cancelLabel: 'No',
                    destructive: destructive,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    vibrations = <Object?>[];
    outcomes = <bool>[];
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            vibrations.add(call.arguments);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('destructive + confirmed → heavy haptic', (tester) async {
    await openDialog(tester, destructive: true);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(outcomes, [true]);
    expect(vibrations, ['HapticFeedbackType.heavyImpact']);
  });

  testWidgets('destructive + cancelled → no haptic', (tester) async {
    await openDialog(tester, destructive: true);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(outcomes, [false]);
    expect(vibrations, isEmpty);
  });

  testWidgets('non-destructive + confirmed → no haptic', (tester) async {
    await openDialog(tester, destructive: false);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(outcomes, [true]);
    expect(vibrations, isEmpty);
  });
}
