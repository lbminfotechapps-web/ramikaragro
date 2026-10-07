import '../entities/report_financial_year.dart';
import '../repositories/monthly_performance_repository.dart';

class GetReportFinancialYears {
  final MonthlyPerformanceRepository
      repository;

  GetReportFinancialYears(
    this.repository,
  );

  Future<List<ReportFinancialYear>>
      call() {
    return repository
        .getReportFinancialYears();
  }
}