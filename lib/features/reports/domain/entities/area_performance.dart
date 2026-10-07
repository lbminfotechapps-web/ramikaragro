class AreaPerformance {
  final List<AreaPerformanceItem> areas;

  final int totalDealers;

  final double totalOrderAmount;
  final int totalOrderCount;

  final double totalDispatchAmount;
  final int totalDispatchCount;

  final double totalCollection;

  final double totalVisitShare;

  final List<String> selectedMonths;

  final String financialYearLabel;

  const AreaPerformance({
    required this.areas,
    required this.totalDealers,
    required this.totalOrderAmount,
    required this.totalOrderCount,
    required this.totalDispatchAmount,
    required this.totalDispatchCount,
    required this.totalCollection,
    required this.totalVisitShare,
    required this.selectedMonths,
    required this.financialYearLabel,
  });
}

class AreaPerformanceItem {
  final String areaName;

  final int visits;

  final double visitShare;

  final double orderAmount;
  final int orderCount;

  final double dispatchAmount;
  final int dispatchCount;

  final double collectionAmount;

  const AreaPerformanceItem({
    required this.areaName,
    required this.visits,
    required this.visitShare,
    required this.orderAmount,
    required this.orderCount,
    required this.dispatchAmount,
    required this.dispatchCount,
    required this.collectionAmount,
  });
}