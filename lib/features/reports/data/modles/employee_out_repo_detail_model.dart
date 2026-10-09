import 'package:solufine/features/reports/domain/entities/employee_out_repo_details.dart';

class EmployeeOutRepoDetailsModel extends EmployeeOutRepoDetailsEntity {
  const EmployeeOutRepoDetailsModel({
    required super.result,
    required super.status,
    required super.message,
  });

  factory EmployeeOutRepoDetailsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeOutRepoDetailsModel(
      result:
          (json['result'] as List<dynamic>?)
              ?.map(
                (item) => EmployeeOutRepoDetailsItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.map((item) {
        return {
          'fld_date': item.date,
          'fld_total_expense': item.totalExpense,
          'fld_total_kilometer': item.totalKilometer,
          'fld_present_status': item.presentStatus,
        };
      }).toList(),
      'status': status,
      'message': message,
    };
  }
}

class EmployeeOutRepoDetailsItemModel extends EmployeeOutRepoDetailsItemEntity {
  const EmployeeOutRepoDetailsItemModel({
    required super.date,
    required super.totalExpense,
    required super.totalKilometer,
    required super.presentStatus,
  });

  factory EmployeeOutRepoDetailsItemModel.fromJson(Map<String, dynamic> json) {
    return EmployeeOutRepoDetailsItemModel(
      date: json['fld_date']?.toString() ?? '',
      totalExpense: json['fld_total_expense']?.toString() ?? '0',
      totalKilometer: json['fld_total_kilometer']?.toString() ?? '0',
      presentStatus: json['fld_present_status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_date': date,
      'fld_total_expense': totalExpense,
      'fld_total_kilometer': totalKilometer,
      'fld_present_status': presentStatus,
    };
  }
}
