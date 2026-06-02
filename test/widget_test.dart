import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/app.dart';

void main() {
  testWidgets('smoke test — app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TendaskApp());
    expect(find.text('Tendask'), findsOneWidget);
  });
}
