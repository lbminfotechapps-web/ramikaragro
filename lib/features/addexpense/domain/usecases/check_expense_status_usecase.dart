import 'package:solufine/features/addexpense/domain/repositories/expense_repository.dart';

class CheckExpenseStatusUseCase {
  final ExpenseRepository repository;

  CheckExpenseStatusUseCase(this.repository);

  Future<int> call({required String userId, required String expenseDate}) {
    return repository.checkExpenseStatus(
      userId: userId,
      expenseDate: expenseDate,
    );
  }
}
