import '../../domain/entities/visit_frequency.dart';

// ============================================================
// HELPER
// ============================================================

int _toInt(
  dynamic value,
) {
  return int.tryParse(
        value?.toString() ?? '0',
      ) ??
      0;
}

double _toDouble(
  dynamic value,
) {
  return double.tryParse(
        value?.toString() ?? '0',
      ) ??
      0.0;
}

// ============================================================
// REPORT MODEL
// ============================================================

class VisitFrequencyReportModel
    extends VisitFrequencyReport {
  const VisitFrequencyReportModel({
    required super.dealer,
    required super.farmer,
    required super.fromDate,
    required super.toDate,
  });

  factory VisitFrequencyReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    // ========================================================
    // DEALER
    // ========================================================

    final dynamic dealerData =
        json['dealer'];

    final VisitFrequencyGroupModel dealer =
        dealerData is Map
            ? VisitFrequencyGroupModel.fromJson(
                Map<String, dynamic>.from(
                  dealerData,
                ),
              )
            : const VisitFrequencyGroupModel(
                total: 0,
                buckets: [],
              );

    // ========================================================
    // FARMER
    // ========================================================

    final dynamic farmerData =
        json['farmer'];

    final VisitFrequencyGroupModel farmer =
        farmerData is Map
            ? VisitFrequencyGroupModel.fromJson(
                Map<String, dynamic>.from(
                  farmerData,
                ),
              )
            : const VisitFrequencyGroupModel(
                total: 0,
                buckets: [],
              );

    return VisitFrequencyReportModel(
      dealer:
          dealer,

      farmer:
          farmer,

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

// ============================================================
// GROUP MODEL
// ============================================================

class VisitFrequencyGroupModel
    extends VisitFrequencyGroup {
  const VisitFrequencyGroupModel({
    required super.total,
    required super.buckets,
  });

  factory VisitFrequencyGroupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawBuckets =
        json['buckets'];

    final List<VisitFrequencyBucketModel>
        buckets =
        rawBuckets is List
            ? rawBuckets
                .whereType<Map>()
                .map(
                  (e) =>
                      VisitFrequencyBucketModel
                          .fromJson(
                    Map<String, dynamic>.from(
                      e,
                    ),
                  ),
                )
                .toList()
            : [];

    return VisitFrequencyGroupModel(
      total:
          _toInt(
        json['total'],
      ),

      buckets:
          buckets,
    );
  }
}

// ============================================================
// BUCKET MODEL
// ============================================================

class VisitFrequencyBucketModel
    extends VisitFrequencyBucket {
  const VisitFrequencyBucketModel({
    required super.key,
    required super.label,
    required super.count,
    required super.percentage,
  });

  factory VisitFrequencyBucketModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitFrequencyBucketModel(
      key:
          json['key']
                  ?.toString() ??
              '',

      label:
          json['label']
                  ?.toString() ??
              '',

      count:
          _toInt(
        json['count'],
      ),

      percentage:
          _toDouble(
        json['percentage'],
      ),
    );
  }
}