import 'package:solufine/features/reports/domain/entities/employee_out_repo_details.dart';

import '../entities/assign_employee.dart';
import '../repositories/employee_output_repository.dart';

class GetEmployees {
  final EmployeeOutputRepository repository;

  GetEmployees(this.repository);

  Future<List<AssignEmployee>> call({
    required String logUserId,
    required String search,
  }) {
    return repository.searchEmployees(logUserId: logUserId, search: search);
  }

  Future<EmployeeOutRepoDetailsEntity> getEmployeeOutputReportDetails({
    required String empId,
    required String fromdate,
    required String toDate,
  }) {
    return repository.getEmployeeOutputReportDetails(
      empId: empId,
      fromdate: fromdate,
      toDate: toDate,
    );
  }
}
