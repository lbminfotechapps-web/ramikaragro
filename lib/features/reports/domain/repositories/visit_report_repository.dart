import '../entities/visit_report.dart';

abstract class VisitReportRepository {
  Future<List<VisitReport>> getVisitReportDetails({
    required String logUserId,
    required String userId,
    required String fromDate,
    required String toDate,
  });
}