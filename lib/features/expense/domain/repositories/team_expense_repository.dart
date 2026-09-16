import '../entities/team_expense_entity.dart';

abstract class TeamExpenseRepository {
  Future<List<TeamExpenseEntity>> getTeamExpenses({
    required int userId,
    required String fromDate,
    required String toDate,
    required String searchText,
    required int startLimit,
  });

  Future<bool> updateTeamExpense({
  required int userId,
  required String expenseId,
  required String expenseJson,
  required String expenseStatus,
  required String remark,
});
}