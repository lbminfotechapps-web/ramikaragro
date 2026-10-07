class HourlyPerformance {
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

  final List<HourlyPerformanceItem> hours;

  const HourlyPerformance({
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
    required this.hours,
  });
}

class HourlyPerformanceItem {
  final String hourKey;
  final String hourLabel;

  final int visits;

  final double visitShare;

  final double orderAmount;
  final int orderCount;

  final double dispatchAmount;
  final int dispatchCount;

  final double collectionAmount;

  const HourlyPerformanceItem({
    required this.hourKey,
    required this.hourLabel,
    required this.visits,
    required this.visitShare,
    required this.orderAmount,
    required this.orderCount,
    required this.dispatchAmount,
    required this.dispatchCount,
    required this.collectionAmount,
  });
}