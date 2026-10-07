import '../../domain/entities/report_financial_year.dart';

class ReportFinancialYearModel
    extends ReportFinancialYear {
  const ReportFinancialYearModel({
    required super.id,
    required super.fromDate,
    required super.toDate,
    required super.label,
  });

  factory ReportFinancialYearModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportFinancialYearModel(
      id:
          json['fy_id']
                  ?.toString()
                  .trim() ??
              '',

      fromDate:
          json['fy_from_date']
                  ?.toString()
                  .trim() ??
              '',

      toDate:
          json['fy_to_date']
                  ?.toString()
                  .trim() ??
              '',

      label:
          json['fy_label']
                  ?.toString()
                  .trim() ??
              '',
    );
  }
}