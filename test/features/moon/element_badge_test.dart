import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/theme/app_theme.dart';
import 'package:tendask/app/theme/moon_colors.dart';
import 'package:tendask/app/theme/theme_palette.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/features/moon/presentation/widgets/element_badge.dart';
import 'package:tendask/i18n/translations.g.dart';

Future<void> _pump(
  WidgetTester tester,
  BiodynamicElement element, {
  ThemeData? theme,
}) =>
    tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: theme ?? AppTheme.light(greenPalette),
          home: Center(child: ElementBadge(element: element)),
        ),
      ),
    );

void main() {
  testWidgets('shows emoji glyph and localized label for every element',
      (tester) async {
    final labels = AppLocale.en.buildSync().moon.day_for;
    for (final element in BiodynamicElement.values) {
      await _pump(tester, element);
      expect(
        find.textContaining(elementEmoji(element)),
        findsOneWidget,
        reason: '$element emoji',
      );
      expect(
        find.text(labels[element.name]!),
        findsOneWidget,
        reason: '$element label',
      );
    }
  });

  test('element emoji are distinct', () {
    expect(
      BiodynamicElement.values.map(elementEmoji).toSet(),
      hasLength(BiodynamicElement.values.length),
    );
  });

  testWidgets('pill background is the element soft tone from the theme',
      (tester) async {
    Color pillColor() {
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ElementBadge),
          matching: find.byType(Container),
        ),
      );
      // The badge's only Container always carries a BoxDecoration.
      return (container.decoration! as BoxDecoration).color!;
    }

    await _pump(tester, BiodynamicElement.fruit);
    expect(pillColor(), moonColorsLight.fruitSoft);

    await _pump(
      tester,
      BiodynamicElement.leaf,
      theme: AppTheme.dark(greenPalette),
    );
    // MaterialApp animates theme changes; settle past the AnimatedTheme lerp.
    await tester.pumpAndSettle();
    expect(pillColor(), moonColorsDark.leafSoft);
  });
}
