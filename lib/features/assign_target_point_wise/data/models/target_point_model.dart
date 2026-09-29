import '../../domain/entities/target_point_entity.dart';

class TargetPointModel
    extends TargetPointEntity {
  const TargetPointModel({
    required super.productGroupId,
    super.enteredPoint,
  });

  factory TargetPointModel.empty({
    required String productGroupId,
  }) {
    return TargetPointModel(
      productGroupId: productGroupId,
      enteredPoint: '',
    );
  }

  factory TargetPointModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TargetPointModel(
      productGroupId:
          json['fld_product_group_id']
                  ?.toString() ??
              '',
      enteredPoint:
          json['target_point']
                  ?.toString() ??
              '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_product_group_id':
          productGroupId,
      'target_point':
          enteredPoint,
    };
  }
}