import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/haptics.dart';

/// Pins the intensity mapping: each semantic action must reach the platform as
/// the expected `HapticFeedbackType`, so a future edit can't silently swap them.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final vibrations = <Object?>[];

  setUp(() {
    vibrations.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          vibrations.add(call.arguments);
        }
        return null;
      },
    );
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  test('taskCompleted → lightImpact', () async {
    AppHaptics.taskCompleted();
    await pumpEventQueue();
    expect(vibrations, ['HapticFeedbackType.lightImpact']);
  });

  test('saved → mediumImpact', () async {
    AppHaptics.saved();
    await pumpEventQueue();
    expect(vibrations, ['HapticFeedbackType.mediumImpact']);
  });

  test('destructiveConfirmed → heavyImpact', () async {
    AppHaptics.destructiveConfirmed();
    await pumpEventQueue();
    expect(vibrations, ['HapticFeedbackType.heavyImpact']);
  });
}
