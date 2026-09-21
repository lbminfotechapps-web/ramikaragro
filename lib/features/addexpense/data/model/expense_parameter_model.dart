import 'package:solufine/features/addexpense/domain/entities/expense_parameter_entity.dart';

class ExpenseParameterModel extends ExpenseParameterEntity {
  const ExpenseParameterModel({
    required super.fldExpId,
    required super.fldExpName,
    required super.fldImageName,
    required super.amount,
    super.imageFile,
  });

  factory ExpenseParameterModel.fromJson(Map<String, dynamic> json) {
    return ExpenseParameterModel(
      fldExpId: json['fld_exp_id']?.toString() ?? '',
      fldExpName: json['fld_exp_name']?.toString() ?? '',
      fldImageName: json['fldImageName']?.toString() ?? '',
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0,
    );
  }

  ExpenseParameterModel copyWith({
    String? fldExpId,
    String? fldExpName,
    String? fldImageName,
    double? amount,
    dynamic imageFile,
  }) {
    return ExpenseParameterModel(
      fldExpId: fldExpId ?? this.fldExpId,
      fldExpName: fldExpName ?? this.fldExpName,
      fldImageName: fldImageName ?? this.fldImageName,
      amount: amount ?? this.amount,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
