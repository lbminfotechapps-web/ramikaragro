import 'package:demo/features/addexpense/domain/repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<bool> call({required Map<String, String> fields}) {
    return repository.submitExpense(fields: fields);
  }
}
