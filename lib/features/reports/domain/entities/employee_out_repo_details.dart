import 'package:equatable/equatable.dart';

class EmployeeOutRepoDetailsEntity extends Equatable {
  final List<EmployeeOutRepoDetailsItemEntity> result;
  final bool status;
  final String message;

  const EmployeeOutRepoDetailsEntity({
    required this.result,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [result, status, message];
}

class EmployeeOutRepoDetailsItemEntity extends Equatable {
  final String date;
  final String totalExpense;
  final String totalKilometer;
  final String presentStatus;

  const EmployeeOutRepoDetailsItemEntity({
    required this.date,
    required this.totalExpense,
    required this.totalKilometer,
    required this.presentStatus,
  });

  @override
  List<Object?> get props => [
    date,
    totalExpense,
    totalKilometer,
    presentStatus,
  ];
}
