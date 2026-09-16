import 'package:demo/features/addexpense/domain/entities/expense_parameter_entity.dart';
import 'package:demo/features/addexpense/domain/entities/vehicle_entity.dart';

abstract class ExpenseRepository {
  Future<List<VehicleEntity>> getVehicles({
    required String userId,
    required String lastDate,
  });

  Future<List<ExpenseParameterEntity>> getExpenseParameters({
    required String userId,
  });

  Future<Map<String, dynamic>> getDAAmount({required String userId});

  Future<Map<String, dynamic>> getExpenseDays({
    required String userId,
    required String expenseDate,
  });

  Future<int> checkExpenseStatus({
    required String userId,
    required String expenseDate,
  });

  Future<bool> submitExpense({required Map<String, String> fields});
}
