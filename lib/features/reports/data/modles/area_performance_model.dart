import '../../domain/entities/area_performance.dart';

class AreaPerformanceModel extends AreaPerformance {
  const AreaPerformanceModel({
    required super.areas,
    required super.totalDealers,
    required super.totalOrderAmount,
    required super.totalOrderCount,
    required super.totalDispatchAmount,
    required super.totalDispatchCount,
    required super.totalCollection,
    required super.totalVisitShare,
    required super.selectedMonths,
    required super.financialYearLabel,
  });

  factory AreaPerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawList =
        json['result'] is List ? json['result'] as List : [];

    final List<AreaPerformanceItem> items = [];

    AreaPerformanceItem? totalItem;

    for (final raw in rawList) {
      final Map<String, dynamic> item =
          Map<String, dynamic>.from(raw as Map);

      final AreaPerformanceItem parsed =
          AreaPerformanceItem(
        areaName:
            item['area_name']?.toString().trim() ?? '',
        visits:
            _toInt(item['visits']),
        visitShare:
            _toDouble(item['visit_share_percent']),
        orderAmount:
            _toDouble(item['order_amount']),
        orderCount:
            _toInt(item['order_count']),
        dispatchAmount:
            _toDouble(item['dispatch_amount']),
        dispatchCount:
            _toInt(item['dispatch_count']),
        collectionAmount:
            _toDouble(item['collection_amount']),
      );

      if (parsed.areaName.toLowerCase() ==
          'total') {
        totalItem = parsed;
      } else {
        items.add(parsed);
      }
    }

    final int totalDealers =
        json['total_dealers'] != null
            ? _toInt(json['total_dealers'])
            : items.fold(
                0,
                (sum, e) => sum + e.visits,
              );

    return AreaPerformanceModel(
      areas: items,
      totalDealers: totalDealers,
      totalOrderAmount:
          totalItem?.orderAmount ??
              items.fold(
                0.0,
                (sum, e) => sum + e.orderAmount,
              ),
      totalOrderCount:
          totalItem?.orderCount ??
              items.fold(
                0,
                (sum, e) => sum + e.orderCount,
              ),
      totalDispatchAmount:
          totalItem?.dispatchAmount ??
              items.fold(
                0.0,
                (sum, e) => sum + e.dispatchAmount,
              ),
      totalDispatchCount:
          totalItem?.dispatchCount ??
              items.fold(
                0,
                (sum, e) => sum + e.dispatchCount,
              ),
      totalCollection:
          totalItem?.collectionAmount ??
              items.fold(
                0.0,
                (sum, e) => sum + e.collectionAmount,
              ),
      totalVisitShare:
          totalItem?.visitShare ?? 100.0,
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
        0.0;
  }
}