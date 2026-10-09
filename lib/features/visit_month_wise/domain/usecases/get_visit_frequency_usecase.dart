import '../entities/visit_frequency.dart';
import '../repositories/visit_month_wise_repository.dart';

class GetVisitFrequencyUseCase {
  final VisitMonthWiseRepository
      repository;

  GetVisitFrequencyUseCase(
    this.repository,
  );

  Future<VisitFrequencyReport> call({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return repository
        .getVisitFrequency(
      fromDate:
          fromDate,

      toDate:
          toDate,

      employeeId:
          employeeId,
    );
  }
}