import '../entities/monthly_performance.dart';
import '../repositories/monthly_performance_repository.dart';

class GetMonthlyPerformanceUseCase {
  final MonthlyPerformanceRepository
      repository;

  GetMonthlyPerformanceUseCase(
    this.repository,
  );

  Future<MonthlyPerformance> call({
    required String employeeId,
    required String financialYear,
  }) {
    return repository
        .getMonthlyPerformance(
      employeeId:
          employeeId,

      financialYear:
          financialYear,
    );
  }
}