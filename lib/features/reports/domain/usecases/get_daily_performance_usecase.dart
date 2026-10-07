import '../entities/daily_performance.dart';

import '../repositories/monthly_performance_repository.dart';

class GetDailyPerformanceUseCase {
  final MonthlyPerformanceRepository
      repository;

  GetDailyPerformanceUseCase(
    this.repository,
  );

  Future<DailyPerformance> call({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return repository
        .getDailyPerformance(
      employeeId:
          employeeId,

      financialYear:
          financialYear,

      selectedMonths:
          selectedMonths,
    );
  }
}