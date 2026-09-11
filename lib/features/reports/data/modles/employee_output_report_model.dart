
import '../../domain/entities/employee_output_report.dart';

class EmployeeOutputReportModel extends EmployeeOutputReport {
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
      // API: fld_adm_name
      empName: json['fld_adm_name']?.toString() ?? '',

      // API: fld_id
      empId: json['fld_id']?.toString() ?? '',

      // API: outlet_cnt
      outletCnt: json['outlet_cnt']?.toString() ?? '0',

      // API: farmer_cnt
      farmerCnt: json['farmer_cnt']?.toString() ?? '0',

      // API: current_cnt
      currentCnt: json['current_cnt']?.toString() ?? '0',

      // API: total_visits
      totalVisits: json['total_visits']?.toString() ?? '0',
    );
  }
}

