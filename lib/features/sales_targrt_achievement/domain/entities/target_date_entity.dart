import 'package:equatable/equatable.dart';

class SalesTargetDateEntity extends Equatable {
  final String monthName;
  final String monthlyCollectionId;

  const SalesTargetDateEntity({
    required this.monthName,
    required this.monthlyCollectionId,
  });

  @override
  List<Object?> get props => [
        monthName,
        monthlyCollectionId,
      ];
}