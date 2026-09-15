import 'package:equatable/equatable.dart';

class SalesTargetEntity extends Equatable {
  final String totalTarget;
  final String totalAchieved;
  final String totalPending;
  final String percentage;

  const SalesTargetEntity({
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