import 'package:demo/features/addexpense/domain/repositories/expense_repository.dart';

class GetDAAmountUseCase {
  final ExpenseRepository repository;

  GetDAAmountUseCase(this.repository);

  Future<Map<String, dynamic>> call({required String userId}) {
    return repository.getDAAmount(userId: userId);
  }
}
