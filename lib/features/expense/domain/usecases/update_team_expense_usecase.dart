import '../repositories/team_expense_repository.dart';

class UpdateTeamExpenseUsecase {
  final TeamExpenseRepository repository;

  UpdateTeamExpenseUsecase({
    required this.repository,
  });

  Future<bool> call({
    required int userId,
    required String expenseId,
    required String expenseJson,
    required String expenseStatus,
    required String remark,
  }) async {
    return await repository.updateTeamExpense(
      userId: userId,
      expenseId: expenseId,
      expenseJson: expenseJson,
      expenseStatus: expenseStatus,
      remark: remark,
    );
  }
}