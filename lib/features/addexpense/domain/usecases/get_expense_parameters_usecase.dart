import 'package:demo/features/addexpense/domain/entities/expense_parameter_entity.dart';
import 'package:demo/features/addexpense/domain/repositories/expense_repository.dart';

class GetExpenseParametersUseCase {
  final ExpenseRepository repository;

  GetExpenseParametersUseCase(this.repository);

  Future<List<ExpenseParameterEntity>> call({required String userId}) {
    return repository.getExpenseParameters(userId: userId);
  }
}
