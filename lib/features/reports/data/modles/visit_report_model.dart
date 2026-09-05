import '../../domain/entities/visit_report.dart';

class VisitReportModel extends VisitReport {
  const VisitReportModel({
    required super.date,
    required super.empCode,
    required super.empName,
    required super.inTime,
    required super.dealerVisit,
    required super.farmerVisit,
    required super.outTime,
    required super.totalTime,
    required super.expenseAmount,
    required super.onMapKm,
    required super.totalKm,
    required super.status,
  });

  factory VisitReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitReportModel(
      date: json['fld_date']?.toString() ?? '',
      empCode: json['fld_emp_code']?.toString() ?? '',
      empName: json['fld_emp_name']?.toString() ?? '',
      inTime: json['fld_in_time']?.toString() ?? '',
      dealerVisit: json['fld_dealer_visit']?.toString() ?? '0',
      farmerVisit: json['fld_farmer_visit']?.toString() ?? '0',
      outTime: json['fld_out_time']?.toString() ?? '',
      totalTime: json['fld_tot_time']?.toString() ?? '',
      expenseAmount: json['fld_exp_amt']?.toString() ?? '0',
      onMapKm: json['fld_on_map_km']?.toString() ?? '0',
      totalKm: json['fld_tot_km']?.toString() ?? '0',
      status: json['fld_status']?.toString() ?? '',
    );
  }
}