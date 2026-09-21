import 'package:solufine/features/addexpense/data/datasource/expense_remote_datasource.dart';
import 'package:solufine/features/addexpense/domain/entities/expense_parameter_entity.dart';
import 'package:solufine/features/addexpense/domain/entities/vehicle_entity.dart';
import 'package:solufine/features/addexpense/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDatasource datasource;

  ExpenseRepositoryImpl(this.datasource);

  @override
  Future<List<VehicleEntity>> getVehicles({
    required String userId,
    required String lastDate,
  }) {
    return datasource.getVehicles(userId: userId, lastDate: lastDate);
  }

  @override
  Future<List<ExpenseParameterEntity>> getExpenseParameters({
    required String userId,
  }) {
    return datasource.getExpenseParameters(userId: userId);
  }

  @override
  Future<Map<String, dynamic>> getDAAmount({
    required String userId,
    required String expenseDate,
  }) {
    return datasource.getDAAmount(userId: userId, expenseDate: expenseDate);
  }

  @override
  Future<Map<String, dynamic>> getExpenseDays({
    required String userId,
    required String expenseDate,
  }) {
    return datasource.getExpenseDays(userId: userId, expenseDate: expenseDate);
  }

  @override
  Future<int> checkExpenseStatus({
    required String userId,
    required String expenseDate,
  }) {
    return datasource.checkExpenseStatus(
      userId: userId,
      expenseDate: expenseDate,
    );
  }

  @override
  Future<bool> submitExpense({required Map<String, String> fields}) {
    return datasource.submitExpense(fields: fields);
  }
}
