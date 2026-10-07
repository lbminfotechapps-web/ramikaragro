/// Quantity is measured in cases; rate is the price of one unit.
double calculateCaseAmount({
  required int quantity,
  required String unitsPerCase,
  required double rate,
}) {
  final units = double.tryParse(unitsPerCase.trim()) ?? 0;
  return quantity * units * rate;
}