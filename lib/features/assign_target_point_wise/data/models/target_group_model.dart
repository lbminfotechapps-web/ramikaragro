import '../../domain/entities/target_group_entity.dart';

class TargetGroupModel extends TargetGroupEntity {
  const TargetGroupModel({
    required super.groupType,
    required super.productGroupId,
    required super.groupPoints,
    required super.pointAssign,
  });

  factory TargetGroupModel.fromJson(Map<String, dynamic> json) {
    return TargetGroupModel(
      groupType: json['fld_group_type']?.toString() ?? '',

      productGroupId: json['fld_product_group_id']?.toString() ?? '',

      groupPoints: json['fld_group_points']?.toString() ?? '0',
      pointAssign: json['fld_group_points_assign']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_group_type': groupType,

      'fld_product_group_id': productGroupId,

      'fld_group_points': groupPoints,
    };
  }
}
