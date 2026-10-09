import '../../domain/entities/visit_month_wise.dart';

// ============================================================
// HELPERS
// ============================================================

int _toInt(dynamic value) {
  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

double _toDouble(dynamic value) {
  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

// ============================================================
// ITEM MODEL
// ============================================================

class VisitMonthWiseItemModel
    extends VisitMonthWiseItem {
  const VisitMonthWiseItemModel({
    required super.monthKey,
    required super.month,
    required super.dealerVisits,
    required super.farmerVisits,
    required super.totalVisits,
    required super.uniqueDealers,
    required super.uniqueFarmers,
    required super.avgVisitsDealer,
    required super.avgVisitsFarmer,
  });

  factory VisitMonthWiseItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitMonthWiseItemModel(
      monthKey:
          json['month_key']?.toString() ?? '',

      month:
          json['month']?.toString() ?? '',

      dealerVisits:
          _toInt(
        json['dealer_visits'],
      ),

      farmerVisits:
          _toInt(
        json['farmer_visits'],
      ),

      totalVisits:
          _toInt(
        json['total_visits'],
      ),

      uniqueDealers:
          _toInt(
        json['unique_dealers'],
      ),

      uniqueFarmers:
          _toInt(
        json['unique_farmers'],
      ),

      avgVisitsDealer:
          _toDouble(
        json['avg_visits_dealer'],
      ),

      avgVisitsFarmer:
          _toDouble(
        json['avg_visits_farmer'],
      ),
    );
  }
}

// ============================================================
// TOTAL MODEL
// ============================================================

class VisitMonthWiseTotalModel
    extends VisitMonthWiseTotal {
  const VisitMonthWiseTotalModel({
    required super.dealerVisits,
    required super.farmerVisits,
    required super.totalVisits,
    required super.uniqueDealers,
    required super.uniqueFarmers,
    required super.uniqueCustomers,
    required super.avgVisitsDealer,
    required super.avgVisitsFarmer,
  });

  factory VisitMonthWiseTotalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitMonthWiseTotalModel(
      dealerVisits:
          _toInt(
        json['dealer_visits'],
      ),

      farmerVisits:
          _toInt(
        json['farmer_visits'],
      ),

      totalVisits:
          _toInt(
        json['total_visits'],
      ),

      uniqueDealers:
          _toInt(
        json['unique_dealers'],
      ),

      uniqueFarmers:
          _toInt(
        json['unique_farmers'],
      ),

      uniqueCustomers:
          _toInt(
        json['unique_customers'],
      ),

      avgVisitsDealer:
          _toDouble(
        json['avg_visits_dealer'],
      ),

      avgVisitsFarmer:
          _toDouble(
        json['avg_visits_farmer'],
      ),
    );
  }
}

// ============================================================
// REPORT MODEL
// ============================================================

class VisitMonthWiseReportModel
    extends VisitMonthWiseReport {
  const VisitMonthWiseReportModel({
    required super.items,
    required super.total,
    required super.fromDate,
    required super.toDate,
  });

  factory VisitMonthWiseReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawResult =
        json['result'];

    final List<VisitMonthWiseItemModel>
        items = rawResult is List
            ? rawResult
                .whereType<Map>()
                .map(
                  (e) =>
                      VisitMonthWiseItemModel
                          .fromJson(
                    Map<String, dynamic>.from(
                      e,
                    ),
                  ),
                )
                .toList()
            : [];

    final dynamic rawTotal =
        json['total'];

    final VisitMonthWiseTotalModel
        total = rawTotal is Map
            ? VisitMonthWiseTotalModel
                .fromJson(
                Map<String, dynamic>.from(
                  rawTotal,
                ),
              )
            : const VisitMonthWiseTotalModel(
                dealerVisits: 0,
                farmerVisits: 0,
                totalVisits: 0,
                uniqueDealers: 0,
                uniqueFarmers: 0,
                uniqueCustomers: 0,
                avgVisitsDealer: 0,
                avgVisitsFarmer: 0,
              );

    return VisitMonthWiseReportModel(
      items:
          items,

      total:
          total,

      fromDate:
          json['from_date']
                  ?.toString() ??
              '',

      toDate:
          json['to_date']
                  ?.toString() ??
              '',
    );
  }
}