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
      fldId: json['fldId'],
      fldAdmName:
          json['fldAdmName']?.toString() ?? '',
    );
  }
}