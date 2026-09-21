import 'package:solufine/features/addexpense/domain/repositories/expense_repository.dart';

class GetExpenseDaysUseCase {
  final ExpenseRepository repository;

  GetExpenseDaysUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String userId,
    required String expenseDate,
  }) {
    return repository.getExpenseDays(userId: userId, expenseDate: expenseDate);
  }
}
