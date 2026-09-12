import 'package:equatable/equatable.dart';

import 'my_expense_detail_entity.dart';

class MyExpenseEntity extends Equatable {
  final String expenseDate;
  final String status;
  final String expenseId;
  final String dailyTotal;
  final String visitedPlace;
  final String travellingMode;
  final String approveAmount;
  final String daExpenses;
  final String statusLevel1;
  final String createdBy;
  final String remark;
  final String statusUpdateBy;
  final String reportingStatus;
  final String adminStatus;

  final List<MyExpenseDetailEntity> details;

  const MyExpenseEntity({
    required this.expenseDate,
    required this.status,
    required this.expenseId,
    required this.dailyTotal,
    required this.visitedPlace,
    required this.travellingMode,
    required this.approveAmount,
    required this.daExpenses,
    required this.statusLevel1,
    required this.createdBy,
    required this.remark,
    required this.statusUpdateBy,
    required this.reportingStatus,
    required this.adminStatus,
    required this.details,
  });

  @override
  List<Object?> get props => [
        expenseDate,
        status,
        expenseId,
        dailyTotal,
        visitedPlace,
        travellingMode,
        approveAmount,
        daExpenses,
        statusLevel1,
        createdBy,
        remark,
        statusUpdateBy,
        reportingStatus,
        adminStatus,
        details,
      ];
}