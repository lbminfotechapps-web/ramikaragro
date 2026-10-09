import '../../domain/entities/visit_hour_wise.dart';

class VisitHourWiseReportModel extends VisitHourWiseReport {
  VisitHourWiseReportModel({
    required super.items,
    required super.total,
    required super.fromDate,
    required super.toDate,
  });

  factory VisitHourWiseReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawItems =
        json['result'] is List ? json['result'] : [];

    return VisitHourWiseReportModel(
      items: rawItems
          .map(
            (e) => VisitHourWiseItemModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      total: VisitHourWiseTotalModel.fromJson(
        Map<String, dynamic>.from(
          json['total'] ?? {},
        ),
      ),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
    );
  }
}

class VisitHourWiseItemModel extends VisitHourWiseItem {
  VisitHourWiseItemModel({
    required super.hour,
    required super.label,
    required super.dealerVisits,
    required super.uniqueDealers,
    required super.farmerVisits,
    required super.uniqueFarmers,
    required super.totalVisits,
    required super.avgVisitsDealer,
    required super.avgVisitsFarmer,
    required super.loadPercentage,
  });

  factory VisitHourWiseItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitHourWiseItemModel(
      hour: _toInt(json['hour']),
      label: json['label']?.toString() ?? '',
      dealerVisits: _toInt(json['dealer_visits']),
      uniqueDealers: _toInt(json['unique_dealers']),
      farmerVisits: _toInt(json['farmer_visits']),
      uniqueFarmers: _toInt(json['unique_farmers']),
      totalVisits: _toInt(json['total_visits']),
      avgVisitsDealer: _toDouble(json['avg_visits_dealer']),
      avgVisitsFarmer: _toDouble(json['avg_visits_farmer']),
      loadPercentage: _toDouble(json['load_percentage']),
    );
  }
}

class VisitHourWiseTotalModel extends VisitHourWiseTotal {
  VisitHourWiseTotalModel({
    required super.dealerVisits,
    required super.farmerVisits,
    required super.totalVisits,
    required super.uniqueDealers,
    required super.uniqueFarmers,
    required super.uniqueCustomers,
    required super.avgVisits,
    required super.avgVisitsDealer,
    required super.avgVisitsFarmer,
  });

  factory VisitHourWiseTotalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitHourWiseTotalModel(
      dealerVisits: _toInt(json['dealer_visits']),
      farmerVisits: _toInt(json['farmer_visits']),
      totalVisits: _toInt(json['total_visits']),
      uniqueDealers: _toInt(json['unique_dealers']),
      uniqueFarmers: _toInt(json['unique_farmers']),
      uniqueCustomers: _toInt(json['unique_customers']),
      avgVisits: _toDouble(json['avg_visits']),
      avgVisitsDealer: _toDouble(json['avg_visits_dealer']),
      avgVisitsFarmer: _toDouble(json['avg_visits_farmer']),
    );
  }
}

int _toInt(dynamic value) {
  return int.tryParse(value?.toString() ?? '0') ?? 0;
}

double _toDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '0') ?? 0.0;
}