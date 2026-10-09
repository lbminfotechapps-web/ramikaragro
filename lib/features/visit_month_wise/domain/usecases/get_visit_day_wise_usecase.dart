import '../entities/visit_day_wise.dart';

import '../repositories/visit_month_wise_repository.dart';

class GetVisitDayWiseUseCase {
  final VisitMonthWiseRepository
      repository;

  GetVisitDayWiseUseCase(
    this.repository,
  );

  Future<VisitDayWiseReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository
        .getVisitDayWise(
      fromDate:
          fromDate,

      toDate:
          toDate,

      employeeId:
          employeeId,
    );
  }
}