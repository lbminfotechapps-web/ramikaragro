import '../entities/my_expense_entity.dart';
import '../repositories/my_expense_repository.dart';

class GetMyExpensesUseCase {
  final MyExpenseRepository repository;

  GetMyExpensesUseCase({
    required this.repository,
  });

  Future<List<MyExpenseEntity>> call({
    required int userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
    return await repository.getMyExpenses(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
    );
  }
}