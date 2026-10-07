class MonthlyPerformance {
  final bool status;
  final String message;

  final String financialYear;
  final String financialYearLabel;

  final int totalVisits;
  final double averageVisit;
  final String bestMonth;

  final double totalOrderAmount;
  final int totalOrderCount;

  final double totalDispatchAmount;
  final int totalDispatchCount;

  final double totalPaymentCollection;

  final List<MonthlyPerformanceItem> months;

  const MonthlyPerformance({
    required this.status,
    required this.message,
    required this.financialYear,
    required this.financialYearLabel,
    required this.totalVisits,
    required this.averageVisit,
    required this.bestMonth,
    required this.totalOrderAmount,
    required this.totalOrderCount,
    required this.totalDispatchAmount,
    required this.totalDispatchCount,
    required this.totalPaymentCollection,
    required this.months,
  });
}

class MonthlyPerformanceItem {
  final String monthKey;
  final String month;

  final int visits;

  final double dailyVisitAvg;
  final double visitShare;

  final double orderAmount;
  final int orderCount;

  final double dispatchAmount;
  final int dispatchCount;

  final double paymentCollection;

  const MonthlyPerformanceItem({
    required this.monthKey,
    required this.month,
    required this.visits,
    required this.dailyVisitAvg,
    required this.visitShare,
    required this.orderAmount,
    required this.orderCount,
    required this.dispatchAmount,
    required this.dispatchCount,
    required this.paymentCollection,
  });
}