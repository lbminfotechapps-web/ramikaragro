import '../../domain/entities/top_dealer_performance.dart';

class TopDealerPerformanceModel
    extends TopDealerPerformance {
  const TopDealerPerformanceModel({
    required super.dealers,
    required super.totalVisits,
    required super.totalOrderCount,
    required super.totalOrderAmount,
    required super.totalDispatchCount,
    required super.totalDispatchAmount,
    required super.totalCollectionAmount,
    required super.selectedMonths,
    required super.financialYearLabel,
  });

  factory TopDealerPerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawList =
        json['result'] is List
            ? json['result'] as List<dynamic>
            : <dynamic>[];

    final Map<String, dynamic> totalJson =
        json['total'] is Map
            ? Map<String, dynamic>.from(
                json['total'] as Map,
              )
            : <String, dynamic>{};

    return TopDealerPerformanceModel(
      dealers: rawList
          .whereType<Map>()
          .map(
            (item) => TopDealerItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      totalVisits: _toInt(totalJson['visits']),
      totalOrderCount: _toInt(totalJson['order_count']),
      totalOrderAmount: _toDouble(totalJson['order_amount']),
      totalDispatchCount: _toInt(totalJson['dispatch_count']),
      totalDispatchAmount: _toDouble(totalJson['dispatch_amount']),
      totalCollectionAmount:
          _toDouble(totalJson['collection_amount']),
      selectedMonths:
          (json['selected_months'] is List)
              ? (json['selected_months'] as List)
                  .map((e) => e.toString())
                  .toList()
              : <String>[],
      financialYearLabel:
          json['fy_label']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }
}

class TopDealerItemModel extends TopDealerItem {
  const TopDealerItemModel({
    required super.rank,
    required super.dealerId,
    required super.name,
    required super.city,
    required super.visits,
    required super.orderCount,
    required super.orderAmount,
    required super.dispatchCount,
    required super.dispatchAmount,
    required super.collectionAmount,
    required super.lastVisit,
  });

  factory TopDealerItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TopDealerItemModel(
      rank: _toInt(json['rank']),
      dealerId: json['dealer_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '-',
      visits: _toInt(json['visits']),
      orderCount: _toInt(json['order_count']),
      orderAmount: _toDouble(json['order_amount']),
      dispatchCount: _toInt(json['dispatch_count']),
      dispatchAmount: _toDouble(json['dispatch_amount']),
      collectionAmount:
          _toDouble(json['collection_amount']),
      lastVisit: json['last_visit']?.toString() ?? '-',
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }
}