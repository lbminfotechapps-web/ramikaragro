import '../../domain/entities/growth_report.dart';

class GrowthReportModel
    extends GrowthReport {
  const GrowthReportModel({
    required super.dealers,
    required super.totals,
    required super.compareYears,
    required super.yearsSelected,
    required super.fromYear,
    required super.toYear,
    required super.totalRows,
  });

  factory GrowthReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> result =
        json['result'] is List
            ? json['result']
            : [];

    final List<dynamic> total =
        json['total'] is List
            ? json['total']
            : [];

    return GrowthReportModel(
      dealers:
          result
              .whereType<Map>()
              .map(
                (e) =>
                    GrowthDealerModel.fromJson(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
              )
              .toList(),

      totals:
          total
              .whereType<Map>()
              .map(
                (e) =>
                    GrowthYearDataModel.fromJson(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
              )
              .toList(),

      compareYears:
          json['compare_years'] is List
              ? (json['compare_years']
                      as List)
                  .map(
                    (e) =>
                        int.tryParse(
                          e.toString(),
                        ) ??
                        0,
                  )
                  .toList()
              : [],

      yearsSelected:
          _toInt(
        json['years_selected'],
      ),

      fromYear:
          _toInt(
        json['from_year'],
      ),

      toYear:
          _toInt(
        json['to_year'],
      ),

      totalRows:
          _toInt(
        json['total_rows'],
      ),
    );
  }
}

class GrowthDealerModel
    extends GrowthDealer {
  const GrowthDealerModel({
    required super.dealerId,
    required super.code,
    required super.name,
    required super.mobile,
    required super.taluka,
    required super.district,
    required super.state,
    required super.years,
  });

  factory GrowthDealerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> years =
        json['years'] is List
            ? json['years']
            : [];

    return GrowthDealerModel(
      dealerId:
          json['dealer_id']
                  ?.toString() ??
              '',

      code:
          json['code']
                  ?.toString() ??
              '',

      name:
          json['name']
                  ?.toString() ??
              '',

      mobile:
          json['mobile']
                  ?.toString() ??
              '',

      taluka:
          json['taluka']
                  ?.toString() ??
              '',

      district:
          json['district']
                  ?.toString() ??
              '',

      state:
          json['state']
                  ?.toString() ??
              '',

      years:
          years
              .whereType<Map>()
              .map(
                (e) =>
                    GrowthYearDataModel.fromJson(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class GrowthYearDataModel
    extends GrowthYearData {
  const GrowthYearDataModel({
    required super.year,
    required super.yearLabel,
    required super.collectionAmount,
    required super.collectionProportionalPercent,
    required super.orderAmount,
    required super.orderProportionalPercent,
    required super.collectionGrowthPercent,
    required super.orderGrowthPercent,
  });

  factory GrowthYearDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GrowthYearDataModel(
      year:
          json['year']
                  ?.toString() ??
              '',

      yearLabel:
          json['year_label']
                  ?.toString() ??
              '',

      collectionAmount:
          _toDouble(
        json['collection_amount'],
      ),

      collectionProportionalPercent:
          _toDouble(
        json[
            'collection_proportional_percent'],
      ),

      orderAmount:
          _toDouble(
        json['order_amount'],
      ),

      orderProportionalPercent:
          _toDouble(
        json[
            'order_proportional_percent'],
      ),

      collectionGrowthPercent:
          json['collection_growth_percent']
                  ?.toString() ??
              'NA',

      orderGrowthPercent:
          json['order_growth_percent']
                  ?.toString() ??
              'NA',
    );
  }
}

int _toInt(
  dynamic value,
) {
  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

double _toDouble(
  dynamic value,
) {
  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}