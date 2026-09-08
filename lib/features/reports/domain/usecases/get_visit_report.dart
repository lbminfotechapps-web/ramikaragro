import '../entities/visit_report.dart';
import '../repositories/visit_report_repository.dart';

class GetVisitReport {
  final VisitReportRepository repository;

  GetVisitReport(this.repository);

  Future<List<VisitReport>> call({
    required String logUserId,
    required String userId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getVisitReportDetails(
      logUserId: logUserId,
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}