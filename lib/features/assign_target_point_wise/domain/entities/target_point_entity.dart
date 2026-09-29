class TargetPointEntity {
  final String productGroupId;

  /// User entered point
  final String enteredPoint;

  const TargetPointEntity({
    required this.productGroupId,
    this.enteredPoint = '',
  });

  double get enteredPointValue {
    return double.tryParse(enteredPoint) ?? 0.0;
  }

  TargetPointEntity copyWith({
    String? productGroupId,
    String? enteredPoint,
  }) {
    return TargetPointEntity(
      productGroupId:
          productGroupId ?? this.productGroupId,
      enteredPoint:
          enteredPoint ?? this.enteredPoint,
    );
  }
}