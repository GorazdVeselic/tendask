/// One supply consumed by a task — the drift-free shape used by the task form
/// buffer and [SuppliesRepository.syncForTask].
class SupplySpec {
  const SupplySpec({required this.supplyId, required this.amount});

  final String supplyId;
  final double amount;
}
