import '../../domain/entities/assign_employee.dart';

class AssignEmployeeModel extends AssignEmployee {
  const AssignEmployeeModel({
    required super.fldId,
    required super.fldAdmName,
  });

  factory AssignEmployeeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssignEmployeeModel(
      fldId: json['fld_id']?.toString() ?? '',
      fldAdmName:
          json['fld_adm_name']?.toString() ?? '',
    );
  }
}