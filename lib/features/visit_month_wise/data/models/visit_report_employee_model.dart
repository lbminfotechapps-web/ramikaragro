import '../../domain/entities/visit_report_employee.dart';

class VisitReportEmployeeModel
    extends VisitReportEmployee {
  const VisitReportEmployeeModel({
    required super.id,
    required super.name,
  });

  factory VisitReportEmployeeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitReportEmployeeModel(
      id:
          json['fld_id']
                  ?.toString() ??
              '',

      name:
          json['fld_adm_name']
                  ?.toString() ??
              '',
    );
  }
}