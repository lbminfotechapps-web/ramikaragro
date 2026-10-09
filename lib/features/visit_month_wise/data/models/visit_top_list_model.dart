import '../../domain/entities/visit_top_list.dart';

// ============================================================
// HELPERS
// ============================================================

int _toInt(dynamic value) {
  return int.tryParse(value?.toString() ?? '0') ?? 0;
}

// ============================================================
// REPORT MODEL
// ============================================================

class VisitTopListReportModel extends VisitTopListReport {
  const VisitTopListReportModel({
    required super.dealer,
    required super.farmer,
    required super.fromDate,
    required super.toDate,
  });

  factory VisitTopListReportModel.fromJson(Map<String, dynamic> json) {
    final dynamic dealerData = json['dealer'];

    final dynamic farmerData = json['farmer'];

    return VisitTopListReportModel(
      dealer: dealerData is Map
          ? VisitTopListGroupModel.fromJson(
              Map<String, dynamic>.from(dealerData),
            )
          : const VisitTopListGroupModel(count: 0, items: [], totalVisits: 0),

      farmer: farmerData is Map
          ? VisitTopListGroupModel.fromJson(
              Map<String, dynamic>.from(farmerData),
            )
          : const VisitTopListGroupModel(count: 0, items: [], totalVisits: 0),

      fromDate: json['from_date']?.toString() ?? '',

      toDate: json['to_date']?.toString() ?? '',
    );
  }
}

// ============================================================
// GROUP MODEL
// ============================================================

class VisitTopListGroupModel extends VisitTopListGroup {
  const VisitTopListGroupModel({
    required super.count,
    required super.items,
    required super.totalVisits,
  });

  factory VisitTopListGroupModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawResult = json['result'];

    final List<VisitTopListItemModel> items = rawResult is List
        ? rawResult
              .whereType<Map>()
              .map(
                (e) => VisitTopListItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : [];

    final dynamic totalData = json['total'];

    int totalVisits = 0;

    if (totalData is Map) {
      totalVisits = _toInt(totalData['visit_count']);
    }

    return VisitTopListGroupModel(
      count: _toInt(json['count']),

      items: items,

      totalVisits: totalVisits,
    );
  }
}

// ============================================================
// ITEM MODEL
// ============================================================

class VisitTopListItemModel extends VisitTopListItem {
  const VisitTopListItemModel({
    required super.rank,
    required super.id,
    required super.name,
    required super.visitCount,
  });

  factory VisitTopListItemModel.fromJson(Map<String, dynamic> json) {
    return VisitTopListItemModel(
      rank: _toInt(json['rank']),

      id: json['id']?.toString() ?? '',

      name: json['name']?.toString() ?? '',

      visitCount: _toInt(json['visit_count']),
    );
  }
}
