class TopDealerPerformance {
  final List<TopDealerItem> dealers;

  final int totalVisits;
  final int totalOrderCount;
  final double totalOrderAmount;
  final int totalDispatchCount;
  final double totalDispatchAmount;
  final double totalCollectionAmount;

  final List<String> selectedMonths;
  final String financialYearLabel;

  const TopDealerPerformance({
    required this.dealers,
    required this.totalVisits,
    required this.totalOrderCount,
    required this.totalOrderAmount,
    required this.totalDispatchCount,
    required this.totalDispatchAmount,
    required this.totalCollectionAmount,
    required this.selectedMonths,
    required this.financialYearLabel,
  });

  String get topDealerName {
    if (dealers.isEmpty) {
      return '-';
    }
    return dealers.first.name;
  }

  int get topDealerVisits {
    if (dealers.isEmpty) {
      return 0;
    }
    return dealers.first.visits;
  }
}

class TopDealerItem {
  final int rank;
  final String dealerId;
  final String name;
  final String city;

  final int visits;

  final int orderCount;
  final double orderAmount;

  final int dispatchCount;
  final double dispatchAmount;

  final double collectionAmount;

  final String lastVisit;

  const TopDealerItem({
    required this.rank,
    required this.dealerId,
    required this.name,
    required this.city,
    required this.visits,
    required this.orderCount,
    required this.orderAmount,
    required this.dispatchCount,
    required this.dispatchAmount,
    required this.collectionAmount,
    required this.lastVisit,
  });
}