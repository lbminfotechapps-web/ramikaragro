import '../entities/visit_top_employee.dart';
import '../repositories/visit_month_wise_repository.dart';

class GetVisitTopEmployeeUseCase {
  final VisitMonthWiseRepository repository;

  GetVisitTopEmployeeUseCase(
    this.repository,
  );

  Future<VisitTopEmployeeReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository.getVisitTopEmployee(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );
  }
}