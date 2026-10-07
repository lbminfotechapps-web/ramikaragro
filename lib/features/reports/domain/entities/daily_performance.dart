class DailyPerformance {
  final bool status;
  final String message;

  final String financialYear;
  final String financialYearLabel;

  final List<String> selectedMonths;

  final int totalVisits;

  final double totalOrderAmount;
  final int totalOrderCount;

  final double totalDispatchAmount;
  final int totalDispatchCount;

  final double totalCollection;

  final double totalVisitShare;

  final List<DailyPerformanceItem> days;

  const DailyPerformance({
    required this.status,
    required this.message,
    required this.financialYear,
    required this.financialYearLabel,
    required this.selectedMonths,
    required this.totalVisits,
    required this.totalOrderAmount,
    required this.totalOrderCount,
    required this.totalDispatchAmount,
    required this.totalDispatchCount,
    required this.totalCollection,
    required this.totalVisitShare,
    required this.days,
  });
}

class DailyPerformanceItem {
  final String dayKey;
  final String dayLabel;

  final int visits;

  final double visitShare;

  final double orderAmount;
  final int orderCount;

  final double dispatchAmount;
  final int dispatchCount;

  final double collectionAmount;

  const DailyPerformanceItem({
    required this.dayKey,
    required this.dayLabel,
    required this.visits,
    required this.visitShare,
    required this.orderAmount,
    required this.orderCount,
    required this.dispatchAmount,
    required this.dispatchCount,
    required this.collectionAmount,
  });
}