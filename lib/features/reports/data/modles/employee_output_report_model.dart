import '../../domain/entities/employee_output_report.dart';

class EmployeeOutputReportModel
    extends EmployeeOutputReport {
  const EmployeeOutputReportModel({
    required super.empName,
    required super.empId,
    required super.outletCnt,
    required super.farmerCnt,
    required super.currentCnt,
    required super.totalVisits,
  });

  factory EmployeeOutputReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmployeeOutputReportModel(
      empName:
          json['fldAdmName']?.toString() ??
          json['emp_name']?.toString() ??
          '',

      empId:
          json['fldId']?.toString() ??
          json['emp_id']?.toString() ??
          '',

      outletCnt:
          json['outletCnt']?.toString() ??
          '0',

      farmerCnt:
          json['farmerCnt']?.toString() ??
          '0',

      currentCnt:
          json['currentCnt']?.toString() ??
          '0',

      totalVisits:
          json['totalVisits']?.toString() ??
          '0',
    );
  }
}