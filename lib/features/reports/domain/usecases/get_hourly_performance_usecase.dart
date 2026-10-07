import '../entities/hourly_performance.dart';
import '../repositories/monthly_performance_repository.dart';

class GetHourlyPerformanceUseCase {
  final MonthlyPerformanceRepository
      repository;

  GetHourlyPerformanceUseCase(
    this.repository,
  );

  Future<HourlyPerformance> call({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return repository
        .getHourlyPerformance(
      employeeId:
          employeeId,

      financialYear:
          financialYear,

      selectedMonths:
          selectedMonths,
    );
  }
}