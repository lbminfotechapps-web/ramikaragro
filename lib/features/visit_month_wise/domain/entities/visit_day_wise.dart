class VisitDayWiseItem {
  final String day;
  final String dayLabel;

  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;

  final int uniqueDealers;
  final int uniqueFarmers;

  final double avgVisitsDealer;
  final double avgVisitsFarmer;

  const VisitDayWiseItem({
    required this.day,
    required this.dayLabel,
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

class VisitDayWiseTotal {
  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;

  final int uniqueDealers;
  final int uniqueFarmers;
  final int uniqueCustomers;

  final double avgVisitsDealer;
  final double avgVisitsFarmer;

  const VisitDayWiseTotal({
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

class VisitDayWiseReport {
  final List<VisitDayWiseItem> items;

  final VisitDayWiseTotal total;

  final String fromDate;
  final String toDate;

  const VisitDayWiseReport({
    required this.items,
    required this.total,
    required this.fromDate,
    required this.toDate,
  });
}