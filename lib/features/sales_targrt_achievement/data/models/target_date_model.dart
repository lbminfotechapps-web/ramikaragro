import '../../domain/entities/target_date_entity.dart';

class SalesTargetDateModel extends SalesTargetDateEntity {
  const SalesTargetDateModel({
    required super.monthName,
    required super.monthlyCollectionId,
  });

  factory SalesTargetDateModel.fromJson(Map<String, dynamic> json) {
    return SalesTargetDateModel(
      monthName: json['month_name']?.toString() ?? '',
      monthlyCollectionId:
          json['fld_monthly_collection_id']?.toString() ?? '',
    );
  }
}