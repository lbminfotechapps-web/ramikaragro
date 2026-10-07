import '../entities/top_dealer_performance.dart';
import '../repositories/monthly_performance_repository.dart';

class GetTopDealerPerformanceUseCase {
  final MonthlyPerformanceRepository repository;

  GetTopDealerPerformanceUseCase(
    this.repository,
  );

  Future<TopDealerPerformance> call({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return repository.getTopDealerPerformance(
      employeeId: employeeId,
      financialYear: financialYear,
      selectedMonths: selectedMonths,
    );
  }
}