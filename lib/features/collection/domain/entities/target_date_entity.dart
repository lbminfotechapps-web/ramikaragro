import 'package:equatable/equatable.dart';

class TargetDateEntity extends Equatable {
  final String monthName;
  final String monthlyCollectionId;

  const TargetDateEntity({
    required this.monthName,
    required this.monthlyCollectionId,
  });

  @override
  List<Object?> get props => [
        monthName,
        monthlyCollectionId,
      ];
}