class TeamExpenseEntity {
  final String expenseDate;
  final String status1;
  final String status;
  final String expenseId;
  final double dailyTotal;
  final double approveAmount;
  final String visitedPlace;
  final String travellingMode;
  final double daExpenses;
  final String createdBy;
  final String remark;
  final String expenseBy;
  final String statusUpdateBy;
  final String reportingStatus;
  final String adminStatus;
  final List<TeamExpenseDetailEntity> details;

  const TeamExpenseEntity({
    required this.expenseDate,
    required this.status1,
    required this.status,
    required this.expenseId,
    required this.dailyTotal,
    required this.approveAmount,
    required this.visitedPlace,
    required this.travellingMode,
    required this.daExpenses,
    required this.createdBy,
    required this.remark,
    required this.expenseBy,
    required this.statusUpdateBy,
    required this.reportingStatus,
    required this.adminStatus,
    required this.details,
  });
}

class TeamExpenseDetailEntity {
  final String expId;
  final String expenseId;
  final double amount;
  final String expenseRemark;
  final String expenseImage;
  final String expenseName;

  const TeamExpenseDetailEntity({
    required this.expId,
    required this.expenseId,
    required this.amount,
    required this.expenseRemark,
    required this.expenseImage,
    required this.expenseName,
  });
}