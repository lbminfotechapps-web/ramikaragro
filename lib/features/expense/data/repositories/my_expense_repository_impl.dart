import '../../domain/entities/my_expense_entity.dart';
import '../../domain/repositories/my_expense_repository.dart';
import '../datasources/my_expense_remote_datasource.dart';

class MyExpenseRepositoryImpl
    implements MyExpenseRepository {
  final MyExpenseRemoteDataSource remoteDataSource;

  MyExpenseRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<MyExpenseEntity>> getMyExpenses({
    required int userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
    return await remoteDataSource.getMyExpenses(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
    );
  }
}