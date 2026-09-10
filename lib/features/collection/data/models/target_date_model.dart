import '../../domain/entities/target_date_entity.dart';

class TargetDateModel extends TargetDateEntity {
  const TargetDateModel({
    required super.monthName,
    required super.monthlyCollectionId,
  });

  factory TargetDateModel.fromJson(Map<String, dynamic> json) {
    return TargetDateModel(
      monthName: json['month_name']?.toString() ?? '',
      monthlyCollectionId:
          json['fld_monthly_collection_id']?.toString() ?? '',
    );
  }
}