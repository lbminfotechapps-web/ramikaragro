import '../entities/team_expense_entity.dart';
import '../repositories/team_expense_repository.dart';

class GetTeamExpensesUsecase {
  final TeamExpenseRepository repository;

  GetTeamExpensesUsecase({
    required this.repository,
  });

  Future<List<TeamExpenseEntity>> call({
    required int userId,
    required String fromDate,
    required String toDate,
    required String searchText,
    required int startLimit,
  }) async {
    return await repository.getTeamExpenses(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      searchText: searchText,
      startLimit: startLimit,
    );
  }
}