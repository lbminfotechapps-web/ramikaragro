import '../entities/area_performance.dart';
import '../repositories/monthly_performance_repository.dart';

class GetAreaPerformanceUseCase {
  final MonthlyPerformanceRepository
      repository;

  GetAreaPerformanceUseCase(
    this.repository,
  );

  Future<AreaPerformance> call({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return repository.getAreaPerformance(
      employeeId: employeeId,
      financialYear: financialYear,
      selectedMonths: selectedMonths,
    );
  }
}