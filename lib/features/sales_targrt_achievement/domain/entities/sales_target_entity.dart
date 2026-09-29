import 'package:equatable/equatable.dart';

class SalesTargetEntity extends Equatable {
  final String totalTarget;
  final String totalAchieved;
  final String totalPending;
  final String percentage;
  final String achievementAmount;

  const SalesTargetEntity({
    required this.totalTarget,
    required this.totalAchieved,
    required this.totalPending,
    required this.percentage,
    required this.achievementAmount,
  });

  @override
  List<Object?> get props => [
        totalTarget,
        totalAchieved,
        totalPending,
        percentage,
        achievementAmount,
      ];
}