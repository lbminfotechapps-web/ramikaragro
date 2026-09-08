import '../entities/assign_employee.dart';
import '../repositories/employee_output_repository.dart';

class SearchEmployees {
  final EmployeeOutputRepository repository;

  SearchEmployees(this.repository);

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