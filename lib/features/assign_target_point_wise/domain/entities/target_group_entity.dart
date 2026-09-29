class TargetGroupEntity {
  final String groupType;
  final String productGroupId;
  final String groupPoints;

  const TargetGroupEntity({
    required this.groupType,
    required this.productGroupId,
    required this.groupPoints,
  });

  double get groupPointsValue {
    return double.tryParse(groupPoints) ?? 0.0;
  }

  TargetGroupEntity copyWith({
    String? groupType,
    String? productGroupId,
    String? groupPoints,
  }) {
    return TargetGroupEntity(
      groupType:
          groupType ?? this.groupType,
      productGroupId:
          productGroupId ?? this.productGroupId,
      groupPoints:
          groupPoints ?? this.groupPoints,
    );
  }
}