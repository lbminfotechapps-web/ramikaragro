class GrowthReport {
  final List<GrowthDealer> dealers;

  final List<GrowthYearData> totals;

  final List<int> compareYears;

  final int yearsSelected;

  final int fromYear;

  final int toYear;

  final int totalRows;

  const GrowthReport({
    required this.dealers,
    required this.totals,
    required this.compareYears,
    required this.yearsSelected,
    required this.fromYear,
    required this.toYear,
    required this.totalRows,
  });
}

class GrowthDealer {
  final String dealerId;

  final String code;

  final String name;

  final String mobile;

  final String taluka;

  final String district;

  final String state;

  final List<GrowthYearData> years;

  const GrowthDealer({
    required this.dealerId,
    required this.code,
    required this.name,
    required this.mobile,
    required this.taluka,
    required this.district,
    required this.state,
    required this.years,
  });
}

class GrowthYearData {
  final String year;

  final String yearLabel;

  final double collectionAmount;

  final double collectionProportionalPercent;

  final double orderAmount;

  final double orderProportionalPercent;

  final String collectionGrowthPercent;

  final String orderGrowthPercent;

  const GrowthYearData({
    required this.year,
    required this.yearLabel,
    required this.collectionAmount,
    required this.collectionProportionalPercent,
    required this.orderAmount,
    required this.orderProportionalPercent,
    required this.collectionGrowthPercent,
    required this.orderGrowthPercent,
  });
}