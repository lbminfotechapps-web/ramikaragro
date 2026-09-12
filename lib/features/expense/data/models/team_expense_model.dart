import '../../domain/entities/team_expense_entity.dart';

class TeamExpenseModel extends TeamExpenseEntity {
  const TeamExpenseModel({
    required super.expenseDate,
    required super.status1,
    required super.status,
    required super.expenseId,
    required super.dailyTotal,
    required super.approveAmount,
    required super.visitedPlace,
    required super.travellingMode,
    required super.daExpenses,
    required super.createdBy,
    required super.remark,
    required super.expenseBy,
    required super.statusUpdateBy,
    required super.reportingStatus,
    required super.adminStatus,
    required super.details,
  });

  factory TeamExpenseModel.fromJson(Map<String, dynamic> json) {
    return TeamExpenseModel(
      expenseDate: json['fld_expense_date']?.toString() ?? '',
      status1: json['fld_status1']?.toString() ?? '',
      status: json['fld_status']?.toString() ?? '',
      expenseId: json['fld_expense_id']?.toString() ?? '',
      dailyTotal:
          double.tryParse(json['fld_daily_tot']?.toString() ?? '0') ?? 0,
      approveAmount:
          double.tryParse(json['fld_approve_amt']?.toString() ?? '0') ?? 0,
      visitedPlace: json['fld_visited_place']?.toString() ?? '',
      travellingMode: json['fld_travelling_mode']?.toString() ?? '',
      daExpenses:
          double.tryParse(json['fld_da_expenses']?.toString() ?? '0') ?? 0,
      createdBy: json['fld_created_by']?.toString() ?? '',
      remark: json['fld_remark']?.toString() ?? '',
      expenseBy: json['fld_expense_by']?.toString() ?? '',
      statusUpdateBy: json['fld_status_update_by']?.toString() ?? '',
      reportingStatus: json['fld_reporting_status']?.toString() ?? '',
      adminStatus: json['fld_admin_status']?.toString() ?? '',
      details: (json['details'] as List? ?? [])
          .map(
            (e) => TeamExpenseDetailModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}

class TeamExpenseDetailModel extends TeamExpenseDetailEntity {
  const TeamExpenseDetailModel({
    required super.expId,
    required super.expenseId,
    required super.amount,
    required super.expenseRemark,
    required super.expenseImage,
    required super.expenseName,
  });

  factory TeamExpenseDetailModel.fromJson(Map<String, dynamic> json) {
    return TeamExpenseDetailModel(
      expId: json['fld_exp_id']?.toString() ?? '',
      expenseId: json['fld_expense_id']?.toString() ?? '',
      amount:
          double.tryParse(json['fld_amount']?.toString() ?? '0') ?? 0,
      expenseRemark: json['fld_expense_remark']?.toString() ?? '',
      expenseImage: json['fld_expense_image']?.toString() ?? '',
      expenseName: json['fld_exp_name']?.toString() ?? '',
    );
  }
}