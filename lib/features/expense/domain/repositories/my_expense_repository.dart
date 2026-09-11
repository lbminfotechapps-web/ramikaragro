import '../entities/my_expense_entity.dart';

abstract class MyExpenseRepository {
  Future<List<MyExpenseEntity>> getMyExpenses({
    required int userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
  });
}