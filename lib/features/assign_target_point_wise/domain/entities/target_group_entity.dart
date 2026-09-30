class TargetGroupEntity {
  final String groupType;
  final String productGroupId;
  final String groupPoints;
  final String pointAssign;

  const TargetGroupEntity({
    required this.groupType,
    required this.productGroupId,
    required this.groupPoints,
    required this.pointAssign,
  });

  double get groupPointsValue {
    return double.tryParse(groupPoints) ?? 0.0;
  }

  TargetGroupEntity copyWith({
    String? groupType,
    String? productGroupId,
    String? groupPoints,
    String? pointAssign,
  }) {
    return TargetGroupEntity(
      groupType: groupType ?? this.groupType,
      productGroupId: productGroupId ?? this.productGroupId,
      groupPoints: groupPoints ?? this.groupPoints,
      pointAssign: pointAssign ?? this.pointAssign,
    );
  }
}
