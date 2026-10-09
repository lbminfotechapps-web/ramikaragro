import '../../domain/entities/visit_geo_wise.dart';

class VisitGeoWiseReportModel extends VisitGeoWiseReport {
  const VisitGeoWiseReportModel({
    required super.stateSection,
    required super.districtSection,
    required super.talukaSection,
    required super.fromDate,
    required super.toDate,
  });

  factory VisitGeoWiseReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitGeoWiseReportModel(
      stateSection: VisitGeoSectionModel.fromJson(
        json['state'] is Map
            ? Map<String, dynamic>.from(json['state'])
            : <String, dynamic>{},
      ),
      districtSection: VisitGeoSectionModel.fromJson(
        json['district'] is Map
            ? Map<String, dynamic>.from(json['district'])
            : <String, dynamic>{},
      ),
      talukaSection: VisitGeoSectionModel.fromJson(
        json['taluka'] is Map
            ? Map<String, dynamic>.from(json['taluka'])
            : <String, dynamic>{},
      ),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
    );
  }
}

class VisitGeoSectionModel extends VisitGeoSection {
  const VisitGeoSectionModel({
    required super.count,
    required super.items,
    required super.total,
  });

  factory VisitGeoSectionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> result =
        json['result'] is List ? json['result'] : [];

    return VisitGeoSectionModel(
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      items: result
          .whereType<Map>()
          .map(
            (e) => VisitGeoItemModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      total: VisitGeoTotalModel.fromJson(
        json['total'] is Map
            ? Map<String, dynamic>.from(json['total'])
            : <String, dynamic>{},
      ),
    );
  }
}

class VisitGeoItemModel extends VisitGeoItem {
  const VisitGeoItemModel({
    required super.id,
    required super.name,
    required super.dealerVisits,
    required super.farmerVisits,
    required super.totalVisits,
    required super.unique,
  });

  factory VisitGeoItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitGeoItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dealerVisits:
          int.tryParse(json['dealer_visits']?.toString() ?? '0') ?? 0,
      farmerVisits:
          int.tryParse(json['farmer_visits']?.toString() ?? '0') ?? 0,
      totalVisits:
          int.tryParse(json['total_visits']?.toString() ?? '0') ?? 0,
      unique: int.tryParse(json['unique']?.toString() ?? '0') ?? 0,
    );
  }
}

class VisitGeoTotalModel extends VisitGeoTotal {
  const VisitGeoTotalModel({
    required super.dealerVisits,
    required super.farmerVisits,
    required super.totalVisits,
    required super.unique,
  });

  factory VisitGeoTotalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitGeoTotalModel(
      dealerVisits:
          int.tryParse(json['dealer_visits']?.toString() ?? '0') ?? 0,
      farmerVisits:
          int.tryParse(json['farmer_visits']?.toString() ?? '0') ?? 0,
      totalVisits:
          int.tryParse(json['total_visits']?.toString() ?? '0') ?? 0,
      unique: int.tryParse(json['unique']?.toString() ?? '0') ?? 0,
    );
  }
}