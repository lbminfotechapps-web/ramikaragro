class VisitMonthWiseItem {
  final String monthKey;
  final String month;

  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;

  final int uniqueDealers;
  final int uniqueFarmers;

  final double avgVisitsDealer;
  final double avgVisitsFarmer;

  const VisitMonthWiseItem({
    required this.monthKey,
    required this.month,
    required this.dealerVisits,
    required this.farmerVisits,
    required this.totalVisits,
    required this.uniqueDealers,
    required this.uniqueFarmers,
    required this.avgVisitsDealer,
    required this.avgVisitsFarmer,
  });
}

// ============================================================
// TOTAL
// ============================================================

class VisitMonthWiseTotal {
  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;

  final int uniqueDealers;
  final int uniqueFarmers;
  final int uniqueCustomers;

  final double avgVisitsDealer;
  final double avgVisitsFarmer;

  const VisitMonthWiseTotal({
    required this.dealerVisits,
    required this.farmerVisits,
    required this.totalVisits,
    required this.uniqueDealers,
    required this.uniqueFarmers,
    required this.uniqueCustomers,
    required this.avgVisitsDealer,
    required this.avgVisitsFarmer,
  });
}

// ============================================================
// REPORT
// ============================================================

class VisitMonthWiseReport {
  final List<VisitMonthWiseItem> items;

  final VisitMonthWiseTotal total;

  final String fromDate;
  final String toDate;

  const VisitMonthWiseReport({
    required this.items,
    required this.total,
    required this.fromDate,
    required this.toDate,
  });
}