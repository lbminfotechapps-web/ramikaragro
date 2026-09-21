import 'package:solufine/features/addexpense/domain/entities/vehicle_entity.dart';
import 'package:solufine/features/addexpense/domain/repositories/expense_repository.dart';

class GetExpenseVehicleUseCase {
  final ExpenseRepository repository;

  GetExpenseVehicleUseCase(this.repository);

  Future<List<VehicleEntity>> call({
    required String userId,
    required String lastDate,
  }) {
    return repository.getVehicles(userId: userId, lastDate: lastDate);
  }
}
