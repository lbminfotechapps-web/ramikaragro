import '../../domain/entities/monthly_performance.dart';

class MonthlyPerformanceModel
    extends MonthlyPerformance {
  const MonthlyPerformanceModel({
    required super.status,
    required super.message,
    required super.financialYear,
    required super.financialYearLabel,
    required super.totalVisits,
    required super.averageVisit,
    required super.bestMonth,
    required super.totalOrderAmount,
    required super.totalOrderCount,
    required super.totalDispatchAmount,
    required super.totalDispatchCount,
    required super.totalPaymentCollection,
    required super.months,
  });

  factory MonthlyPerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawResult =
        json['result'] is List
            ? json['result']
            : <dynamic>[];

    final List<MonthlyPerformanceItem>
        months = [];

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

      final String monthKey =
          row['month_key']
                  ?.toString()
                  .trim() ??
              '';

      if (monthKey ==
          'total_selected') {
        totalRow = row;

        continue;
      }

      months.add(
        MonthlyPerformanceItemModel
            .fromJson(
          row,
        ),
      );
    }

    final Map<String, dynamic> total =
        totalRow ??
            <String, dynamic>{};

    // ==========================================================
    // FIND BEST MONTH
    // ==========================================================

    String bestMonth =
        '-';

    int highestVisits =
        0;

    for (final item in months) {
      if (item.visits >
          highestVisits) {
        highestVisits =
            item.visits;

        bestMonth =
            item.month;
      }
    }

    return MonthlyPerformanceModel(
      status:
          json['status'] ==
                  true ||
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

      totalVisits:
          _toInt(
        total['visits'],
      ),

      averageVisit:
          _toDouble(
        total[
            'daily_visit_avg'],
      ),

      bestMonth:
          bestMonth,

      totalOrderAmount:
          _toDouble(
        total[
            'order_amount'],
      ),

      totalOrderCount:
          _toInt(
        total[
            'order_count'],
      ),

      totalDispatchAmount:
          _toDouble(
        total[
            'dispatch_amount'],
      ),

      totalDispatchCount:
          _toInt(
        total[
            'dispatch_count'],
      ),

      totalPaymentCollection:
          _toDouble(
        total[
            'collection_amount'],
      ),

      months:
          months,
    );
  }
}

// ============================================================
// MONTH MODEL
// ============================================================

class MonthlyPerformanceItemModel
    extends MonthlyPerformanceItem {
  const MonthlyPerformanceItemModel({
    required super.monthKey,
    required super.month,
    required super.visits,
    required super.dailyVisitAvg,
    required super.visitShare,
    required super.orderAmount,
    required super.orderCount,
    required super.dispatchAmount,
    required super.dispatchCount,
    required super.paymentCollection,
  });

  factory MonthlyPerformanceItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MonthlyPerformanceItemModel(
      monthKey:
          json['month_key']
                  ?.toString() ??
              '',

      month:
          json['month_label']
                  ?.toString() ??
              '',

      visits:
          _toInt(
        json['visits'],
      ),

      dailyVisitAvg:
          _toDouble(
        json[
            'daily_visit_avg'],
      ),

      visitShare:
          _toDouble(
        json[
            'visit_share_percent'],
      ),

      orderAmount:
          _toDouble(
        json[
            'order_amount'],
      ),

      orderCount:
          _toInt(
        json[
            'order_count'],
      ),

      dispatchAmount:
          _toDouble(
        json[
            'dispatch_amount'],
      ),

      dispatchCount:
          _toInt(
        json[
            'dispatch_count'],
      ),

      paymentCollection:
          _toDouble(
        json[
            'collection_amount'],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

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

  final String text =
      value.toString().trim();

  return int.tryParse(
        text,
      ) ??
      double.tryParse(
            text,
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
        value
            .toString()
            .trim(),
      ) ??
      0;
}