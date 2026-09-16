import '../../domain/entities/collection_target_entity.dart';

class CollectionTargetModel extends CollectionTargetEntity {
  const CollectionTargetModel({
    required super.totalTarget,
    required super.totalAchieved,
    required super.totalPending,
    required super.percentage,
  });

  factory CollectionTargetModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CollectionTargetModel(
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