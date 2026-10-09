import '../entities/visit_hour_wise.dart';
import '../repositories/visit_month_wise_repository.dart';

class GetVisitHourWiseUseCase {
  final VisitMonthWiseRepository repository;

  GetVisitHourWiseUseCase(
    this.repository,
  );

  Future<VisitHourWiseReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository.getVisitHourWise(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );
  }
}