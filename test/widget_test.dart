import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/app.dart';

void main() {
  testWidgets('smoke test — app renders with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TendaskApp()));
    expect(find.text('Tendask'), findsOneWidget);
  });
}
