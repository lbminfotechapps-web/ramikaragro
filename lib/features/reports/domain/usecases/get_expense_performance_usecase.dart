import '../entities/expense_performance.dart';
import '../repositories/monthly_performance_repository.dart';

class GetExpensePerformanceUseCase {
  final MonthlyPerformanceRepository
      repository;

  GetExpensePerformanceUseCase(
    this.repository,
  );

  Future<ExpensePerformance> call({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return repository
        .getExpensePerformance(
      employeeId:
          employeeId,
      financialYear:
          financialYear,
      selectedMonths:
          selectedMonths,
    );
  }
}