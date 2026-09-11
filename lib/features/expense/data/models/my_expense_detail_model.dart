import '../../domain/entities/my_expense_detail_entity.dart';

class MyExpenseDetailModel extends MyExpenseDetailEntity {
  const MyExpenseDetailModel({
    required super.expId,
    required super.expenseId,
    required super.amount,
    required super.expenseRemark,
    required super.expenseImage,
    required super.expName,
  });

  factory MyExpenseDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MyExpenseDetailModel(
      expId: json['fld_exp_id']?.toString() ?? '',
      expenseId:
          json['fld_expense_id']?.toString() ?? '',
      amount:
          json['fld_amount']?.toString() ?? '0.00',
      expenseRemark:
          json['fld_expense_remark']?.toString() ?? '',
      expenseImage:
          json['fld_expense_image']?.toString() ?? '',
      expName:
          json['fld_exp_name']?.toString() ?? '',
    );
  }
}