import 'yield_unit.dart';

/// One recorded harvest: the calendar year it happened and how much.
typedef YieldRecord = ({int year, double amount, YieldUnit unit});

/// All-time totals plus a per-year breakdown for one plant's harvests.
/// Amounts are grouped by unit — kg and pieces are never summed together.
class YieldSummary {
  const YieldSummary({required this.totals, required this.byYear});

  /// All-time total per unit (only units that actually occur).
  final Map<YieldUnit, double> totals;

  /// Per-year totals per unit, newest year first.
  final List<YieldYear> byYear;

  bool get isEmpty => totals.isEmpty;

  static const empty = YieldSummary(totals: {}, byYear: []);
}

class YieldYear {
  const YieldYear({required this.year, required this.totals});
  final int year;
  final Map<YieldUnit, double> totals;
}

/// Aggregates harvest records into all-time and per-year totals per unit.
/// Pure (no I/O) so the plant-detail summary is unit-testable.
YieldSummary summarizeYield(Iterable<YieldRecord> records) {
  final totals = <YieldUnit, double>{};
  final perYear = <int, Map<YieldUnit, double>>{};

  for (final r in records) {
    totals.update(r.unit, (v) => v + r.amount, ifAbsent: () => r.amount);
    final year = perYear.putIfAbsent(r.year, () => {});
    year.update(r.unit, (v) => v + r.amount, ifAbsent: () => r.amount);
  }

  if (totals.isEmpty) return YieldSummary.empty;

  final years = perYear.keys.toList()..sort((a, b) => b.compareTo(a));
  return YieldSummary(
    totals: totals,
    byYear: [
      for (final y in years) YieldYear(year: y, totals: perYear[y]!),
    ],
  );
}
