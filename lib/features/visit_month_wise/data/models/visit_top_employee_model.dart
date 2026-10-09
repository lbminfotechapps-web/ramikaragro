import '../../domain/entities/visit_top_employee.dart';

// ============================================================
// HELPERS
// ============================================================

int _toInt(dynamic value) {
  return int.tryParse(value?.toString() ?? '0') ?? 0;
}

double _toDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '0') ?? 0;
}

// ============================================================
// REPORT MODEL
// ============================================================

class VisitTopEmployeeReportModel extends VisitTopEmployeeReport {
  const VisitTopEmployeeReportModel({
    required super.items,
    required super.total,
    required super.periodLabel,
    required super.fromDate,
    required super.toDate,
  });

  factory VisitTopEmployeeReportModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawResult = json['result'];

    final List<VisitTopEmployeeItemModel> items = rawResult is List
        ? rawResult
              .whereType<Map>()
              .map(
                (e) => VisitTopEmployeeItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : [];

    final dynamic rawTotal = json['total'];

    final VisitTopEmployeeTotalModel total = rawTotal is Map
        ? VisitTopEmployeeTotalModel.fromJson(
            Map<String, dynamic>.from(rawTotal),
          )
        : const VisitTopEmployeeTotalModel(
            dealerVisits: 0,
            uniqueDealers: 0,
            avgVisitsDealer: 0,
            farmerVisits: 0,
            uniqueFarmers: 0,
            avgVisitsFarmer: 0,
            totalVisits: 0,
          );

    return VisitTopEmployeeReportModel(
      items: items,

      total: total,

      periodLabel: json['period_label']?.toString() ?? '',

      fromDate: json['from_date']?.toString() ?? '',

      toDate: json['to_date']?.toString() ?? '',
    );
  }
}

// ============================================================
// ITEM MODEL
// ============================================================

class VisitTopEmployeeItemModel extends VisitTopEmployeeItem {
  const VisitTopEmployeeItemModel({
    required super.rank,
    required super.userId,
    required super.userName,
    required super.dealerVisits,
    required super.uniqueDealers,
    required super.avgVisitsDealer,
    required super.farmerVisits,
    required super.uniqueFarmers,
    required super.avgVisitsFarmer,
    required super.totalVisits,
  });

  factory VisitTopEmployeeItemModel.fromJson(Map<String, dynamic> json) {
    return VisitTopEmployeeItemModel(
      rank: _toInt(json['rank']),

      userId: json['user_id']?.toString() ?? '',

      userName: json['user_name']?.toString() ?? '',

      dealerVisits: _toInt(json['dealer_visits']),

      uniqueDealers: _toInt(json['unique_dealers']),

      avgVisitsDealer: _toDouble(json['avg_visits_dealer']),

      farmerVisits: _toInt(json['farmer_visits']),

      uniqueFarmers: _toInt(json['unique_farmers']),

      avgVisitsFarmer: _toDouble(json['avg_visits_farmer']),

      totalVisits: _toInt(json['total_visits']),
    );
  }
}

// ============================================================
// TOTAL MODEL
// ============================================================

class VisitTopEmployeeTotalModel extends VisitTopEmployeeTotal {
  const VisitTopEmployeeTotalModel({
    required super.dealerVisits,
    required super.uniqueDealers,
    required super.avgVisitsDealer,
    required super.farmerVisits,
    required super.uniqueFarmers,
    required super.avgVisitsFarmer,
    required super.totalVisits,
  });

  factory VisitTopEmployeeTotalModel.fromJson(Map<String, dynamic> json) {
    return VisitTopEmployeeTotalModel(
      dealerVisits: _toInt(json['dealer_visits']),

      uniqueDealers: _toInt(json['unique_dealers']),

      avgVisitsDealer: _toDouble(json['avg_visits_dealer']),

      farmerVisits: _toInt(json['farmer_visits']),

      uniqueFarmers: _toInt(json['unique_farmers']),

      avgVisitsFarmer: _toDouble(json['avg_visits_farmer']),

      totalVisits: _toInt(json['total_visits']),
    );
  }
}
