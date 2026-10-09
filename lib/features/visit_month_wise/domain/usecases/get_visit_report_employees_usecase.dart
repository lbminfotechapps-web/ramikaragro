import '../entities/visit_report_employee.dart';

import '../repositories/visit_month_wise_repository.dart';

class GetVisitReportEmployeesUseCase {
  final VisitMonthWiseRepository
      repository;

  GetVisitReportEmployeesUseCase(
    this.repository,
  );

  Future<List<VisitReportEmployee>>
      call({
    required String userId,
    required String searchText,
  }) {
    return repository
        .getAssignedEmployees(
      userId:
          userId,

      searchText:
          searchText,
    );
  }
}