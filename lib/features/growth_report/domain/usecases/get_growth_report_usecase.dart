import '../entities/growth_report.dart';

import '../repositories/growth_report_repository.dart';

class GetGrowthReportUseCase {
  final GrowthReportRepository
      repository;

  GetGrowthReportUseCase(
    this.repository,
  );

  Future<GrowthReport> call({
    required String userId,
    required String years,
    required String dealerId,
    required int startLimit,
  }) {
    return repository.getGrowthReport(
      userId:
          userId,

      years:
          years,

      dealerId:
          dealerId,

      startLimit:
          startLimit,
    );
  }
}