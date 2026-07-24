import '../../../core/database/app_database.dart';
import '../../../i18n/translations.g.dart';
import '../yield_unit.dart';

/// Localized short label for a yield unit (kg, kom/pcs, šop/bunch, …).
String yieldUnitLabel(YieldUnit unit, Translations t) => switch (unit) {
  YieldUnit.kg => t.harvest.unit_kg,
  YieldUnit.dag => t.harvest.unit_dag,
  YieldUnit.g => t.harvest.unit_g,
  YieldUnit.pieces => t.harvest.unit_pieces,
  YieldUnit.l => t.harvest.unit_l,
  YieldUnit.bunch => t.harvest.unit_bunch,
};

/// Formats a yield amount: whole numbers drop the decimals, otherwise up to two
/// trimmed decimals. The separator follows the active locale (comma for sl/de).
String formatYieldAmount(double amount) {
  final isWhole = amount == amount.roundToDouble();
  final raw = isWhole
      ? amount.toInt().toString()
      : amount
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
  final isEnglish = LocaleSettings.currentLocale.languageTag.startsWith('en');
  return isEnglish ? raw : raw.replaceAll('.', ',');
}

/// Full yield label, e.g. "2,5 kg". A null unit (unknown value from a newer app
/// version) falls back to the bare amount.
String formatYield(double amount, YieldUnit? unit, Translations t) {
  final amountText = formatYieldAmount(amount);
  return unit == null ? amountText : '$amountText ${yieldUnitLabel(unit, t)}';
}

/// The "🧺 2,5 kg" chip for a task's recorded yield, or null when none — one
/// source for the journal tile and the plant history row.
String? taskYieldChip(Task task, Translations t) {
  final amount = task.yieldAmount;
  if (amount == null) return null;
  return '🧺 ${formatYield(amount, yieldUnitFromName(task.yieldUnit), t)}';
}
