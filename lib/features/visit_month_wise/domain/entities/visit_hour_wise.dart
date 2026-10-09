class VisitHourWiseReport {
  final List<VisitHourWiseItem> items;
  final VisitHourWiseTotal total;
  final String fromDate;
  final String toDate;

  const VisitHourWiseReport({
    required this.items,
    required this.total,
    required this.fromDate,
    required this.toDate,
  });
}

class VisitHourWiseItem {
  final int hour;
  final String label;
  final int dealerVisits;
  final int uniqueDealers;
  final int farmerVisits;
  final int uniqueFarmers;
  final int totalVisits;
  final double avgVisitsDealer;
  final double avgVisitsFarmer;
  final double loadPercentage;

  const VisitHourWiseItem({
    required this.hour,
    required this.label,
    required this.dealerVisits,
    required this.uniqueDealers,
    required this.farmerVisits,
    required this.uniqueFarmers,
    required this.totalVisits,
    required this.avgVisitsDealer,
    required this.avgVisitsFarmer,
    required this.loadPercentage,
  });
}

class VisitHourWiseTotal {
  final int dealerVisits;
  final int farmerVisits;
  final int totalVisits;
  final int uniqueDealers;
  final int uniqueFarmers;
  final int uniqueCustomers;
  final double avgVisits;
  final double avgVisitsDealer;
  final double avgVisitsFarmer;

  const VisitHourWiseTotal({
    required this.dealerVisits,
    required this.farmerVisits,
    required this.totalVisits,
    required this.uniqueDealers,
    required this.uniqueFarmers,
    required this.uniqueCustomers,
    required this.avgVisits,
    required this.avgVisitsDealer,
    required this.avgVisitsFarmer,
  });
}