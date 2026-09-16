import 'package:equatable/equatable.dart';

class CollectionTargetEntity extends Equatable {
  final String totalTarget;
  final String totalAchieved;
  final String totalPending;
  final String percentage;

  const CollectionTargetEntity({
    required this.totalTarget,
    required this.totalAchieved,
    required this.totalPending,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
        totalTarget,
        totalAchieved,
        totalPending,
        percentage,
      ];
}