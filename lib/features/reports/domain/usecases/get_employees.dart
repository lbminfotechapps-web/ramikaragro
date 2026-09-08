import '../entities/assign_employee.dart';
import '../repositories/employee_output_repository.dart';

class GetEmployees {
  final EmployeeOutputRepository repository;

  GetEmployees(
    this.repository,
  );

  Future<List<AssignEmployee>> call({
    required String logUserId,
    required String search,
  }) {
    return repository.searchEmployees(
      logUserId: logUserId,
      search: search,
    );
  }
}