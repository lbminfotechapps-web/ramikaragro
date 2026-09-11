import '../../domain/entities/my_expense_entity.dart';
import 'my_expense_detail_model.dart';

class MyExpenseModel extends MyExpenseEntity {
  const MyExpenseModel({
    required super.expenseDate,
    required super.status,
    required super.expenseId,
    required super.dailyTotal,
    required super.visitedPlace,
    required super.travellingMode,
    required super.approveAmount,
    required super.daExpenses,
    required super.statusLevel1,
    required super.createdBy,
    required super.remark,
    required super.statusUpdateBy,
    required super.reportingStatus,
    required super.adminStatus,
    required super.details,
  });

  factory MyExpenseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<MyExpenseDetailModel> detailList = [];

    final details = json['details'];

    if (details is List) {
      for (final item in details) {
        if (item is Map<String, dynamic>) {
          detailList.add(
            MyExpenseDetailModel.fromJson(item),
          );
        }
      }
    }

    return MyExpenseModel(
      expenseDate:
          json['fld_expense_date']?.toString() ?? '',
      status:
          json['fld_status']?.toString() ?? '0',
      expenseId:
          json['fld_expense_id']?.toString() ?? '',
      dailyTotal:
          json['fld_daily_tot']?.toString() ?? '0.00',
      visitedPlace:
          json['fld_visited_place']?.toString() ?? '',
      travellingMode:
          json['fld_travelling_mode']?.toString() ?? '',
      approveAmount:
          json['fld_approve_amt']?.toString() ?? '0.00',
      daExpenses:
          json['fld_da_expenses']?.toString() ?? '0.00',
      statusLevel1:
          json['fld_status_level1']?.toString() ?? '0',
      createdBy:
          json['fld_created_by']?.toString() ?? '',
      remark:
          json['fld_remark']?.toString() ?? '',
      statusUpdateBy:
          json['fld_status_update_by']?.toString() ?? '',
      reportingStatus:
          json['fld_reporting_status']?.toString() ?? '',
      adminStatus:
          json['fld_admin_status']?.toString() ?? '',
      details: detailList,
    );
  }
}