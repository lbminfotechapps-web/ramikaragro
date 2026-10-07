class ReportFinancialYear {
  final String id;
  final String fromDate;
  final String toDate;
  final String label;

  const ReportFinancialYear({
    required this.id,
    required this.fromDate,
    required this.toDate,
    required this.label,
  });

  @override
  String toString() {
    return label;
  }
}