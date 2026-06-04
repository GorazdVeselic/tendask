import 'translations.g.dart';

/// Registers cardinal plural resolvers for sl and de — slang ships no built-in
/// rules for them, so plural keys would otherwise fall back to the wrong form
/// (and log a warning). Called from main() and the test bootstrap
/// (test/flutter_test_config.dart) so both runtime and tests resolve correctly.
void configurePluralResolvers() {
  // Slovene CLDR cardinal: one = n%100==1, two = n%100==2, few = n%100∈{3,4}.
  LocaleSettings.setPluralResolverSync(
    language: 'sl',
    cardinalResolver: (n, {zero, one, two, few, many, other}) {
      final mod = n.toInt() % 100;
      if (mod == 1) return one ?? other!;
      if (mod == 2) return two ?? other!;
      if (mod == 3 || mod == 4) return few ?? other!;
      return other!;
    },
  );
  LocaleSettings.setPluralResolverSync(
    language: 'de',
    cardinalResolver: (n, {zero, one, two, few, many, other}) =>
        n == 1 ? (one ?? other!) : other!,
  );
}
