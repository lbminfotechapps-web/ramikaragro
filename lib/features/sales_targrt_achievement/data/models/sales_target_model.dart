
import 'package:demo/features/sales_targrt_achievement/domain/entities/sales_target_entity.dart';

class SalesTargetModel extends SalesTargetEntity {
  const SalesTargetModel({
    required super.totalTarget,
    required super.totalAchieved,
    required super.totalPending,
    required super.percentage,
  });

  factory SalesTargetModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesTargetModel(
      totalTarget:
          json['total_target']?.toString() ?? '0',
      totalAchieved:
          json['total_achieved']?.toString() ?? '0',
      totalPending:
          json['total_pending']?.toString() ?? '0',
      percentage:
          json['percentage']?.toString() ?? '0',
    );
  }
}