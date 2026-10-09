import '../entities/visit_month_wise.dart';

import '../repositories/visit_month_wise_repository.dart';

class GetVisitMonthWiseUseCase {
  final VisitMonthWiseRepository
      repository;

  GetVisitMonthWiseUseCase(
    this.repository,
  );

  Future<VisitMonthWiseReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository
        .getVisitMonthWise(
      fromDate:
          fromDate,

      toDate:
          toDate,

      employeeId:
          employeeId,
    );
  }
}