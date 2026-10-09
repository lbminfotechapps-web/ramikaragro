class VisitTopEmployeeReport {
  final List<VisitTopEmployeeItem> items;

  final VisitTopEmployeeTotal total;

  final String periodLabel;

  final String fromDate;

  final String toDate;

  const VisitTopEmployeeReport({
    required this.items,
    required this.total,
    required this.periodLabel,
    required this.fromDate,
    required this.toDate,
  });
}

// ============================================================
// ITEM
// ============================================================

class VisitTopEmployeeItem {
  final int rank;

  final String userId;

  final String userName;

  final int dealerVisits;

  final int uniqueDealers;

  final double avgVisitsDealer;

  final int farmerVisits;

  final int uniqueFarmers;

  final double avgVisitsFarmer;

  final int totalVisits;

  const VisitTopEmployeeItem({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.dealerVisits,
    required this.uniqueDealers,
    required this.avgVisitsDealer,
    required this.farmerVisits,
    required this.uniqueFarmers,
    required this.avgVisitsFarmer,
    required this.totalVisits,
  });
}

// ============================================================
// TOTAL
// ============================================================

class VisitTopEmployeeTotal {
  final int dealerVisits;

  final int uniqueDealers;

  final double avgVisitsDealer;

  final int farmerVisits;

  final int uniqueFarmers;

  final double avgVisitsFarmer;

  final int totalVisits;

  const VisitTopEmployeeTotal({
    required this.dealerVisits,
    required this.uniqueDealers,
    required this.avgVisitsDealer,
    required this.farmerVisits,
    required this.uniqueFarmers,
    required this.avgVisitsFarmer,
    required this.totalVisits,
  });
}
