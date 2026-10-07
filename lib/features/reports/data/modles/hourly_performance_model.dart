import '../../domain/entities/hourly_performance.dart';

class HourlyPerformanceModel
    extends HourlyPerformance {
  const HourlyPerformanceModel({
    required super.status,
    required super.message,
    required super.financialYear,
    required super.financialYearLabel,
    required super.selectedMonths,
    required super.totalVisits,
    required super.totalOrderAmount,
    required super.totalOrderCount,
    required super.totalDispatchAmount,
    required super.totalDispatchCount,
    required super.totalCollection,
    required super.totalVisitShare,
    required super.hours,
  });

  factory HourlyPerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawResult =
        json['result'] is List
            ? json['result']
            : <dynamic>[];

    final List<HourlyPerformanceItem>
        hours = [];

    Map<String, dynamic>? totalRow;

    for (final dynamic raw
        in rawResult) {
      if (raw is! Map) {
        continue;
      }

      final Map<String, dynamic> row =
          Map<String, dynamic>.from(
        raw,
      );

      final String hourKey =
          row['hour_key']
                  ?.toString()
                  .trim() ??
              '';

      // ========================================================
      // TOTAL ROW
      // ========================================================

      if (hourKey ==
          'total_selected') {
        totalRow = row;

        continue;
      }

      hours.add(
        HourlyPerformanceItemModel
            .fromJson(
          row,
        ),
      );
    }

    final Map<String, dynamic> total =
        totalRow ??
            <String, dynamic>{};

    final List<String> selectedMonths =
        json['selected_months'] is List
            ? (json['selected_months']
                    as List)
                .map(
                  (e) =>
                      e.toString(),
                )
                .toList()
            : <String>[];

    return HourlyPerformanceModel(
      status:
          json['status'] == true ||
              json['status']
                      ?.toString()
                      .toLowerCase() ==
                  'true',

      message:
          json['message']
                  ?.toString() ??
              '',

      financialYear:
          json['fy_year']
                  ?.toString() ??
              '',

      financialYearLabel:
          json['fy_label']
                  ?.toString() ??
              '',

      selectedMonths:
          selectedMonths,

      totalVisits:
          _toInt(
        total['visits'],
      ),

      totalOrderAmount:
          _toDouble(
        total['order_amount'],
      ),

      totalOrderCount:
          _toInt(
        total['order_count'],
      ),

      totalDispatchAmount:
          _toDouble(
        total['dispatch_amount'],
      ),

      totalDispatchCount:
          _toInt(
        total['dispatch_count'],
      ),

      totalCollection:
          _toDouble(
        total['collection_amount'],
      ),

      totalVisitShare:
          _toDouble(
        total[
            'visit_share_percent'],
      ),

      hours:
          hours,
    );
  }
}

class HourlyPerformanceItemModel
    extends HourlyPerformanceItem {
  const HourlyPerformanceItemModel({
    required super.hourKey,
    required super.hourLabel,
    required super.visits,
    required super.visitShare,
    required super.orderAmount,
    required super.orderCount,
    required super.dispatchAmount,
    required super.dispatchCount,
    required super.collectionAmount,
  });

  factory HourlyPerformanceItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HourlyPerformanceItemModel(
      hourKey:
          json['hour_key']
                  ?.toString() ??
              '',

      hourLabel:
          json['hour_label']
                  ?.toString() ??
              '',

      visits:
          _toInt(
        json['visits'],
      ),

      visitShare:
          _toDouble(
        json[
            'visit_share_percent'],
      ),

      orderAmount:
          _toDouble(
        json['order_amount'],
      ),

      orderCount:
          _toInt(
        json['order_count'],
      ),

      dispatchAmount:
          _toDouble(
        json['dispatch_amount'],
      ),

      dispatchCount:
          _toInt(
        json['dispatch_count'],
      ),

      collectionAmount:
          _toDouble(
        json[
            'collection_amount'],
      ),
    );
  }
}

int _toInt(
  dynamic value,
) {
  if (value == null) {
    return 0;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value.toString(),
      ) ??
      double.tryParse(
            value.toString(),
          )
              ?.toInt() ??
          0;
}

double _toDouble(
  dynamic value,
) {
  if (value == null) {
    return 0;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value.toString(),
      ) ??
      0;
}