import '../entities/assign_employee.dart';
import '../entities/employee_output_report.dart';

abstract class EmployeeOutputRepository {
  Future<List<EmployeeOutputReport>>
      getEmployeeOutputReport({
    required String userId,
    required String employeeId,
    required String fromDate,
    required String toDate,
    required String employeeName,
    required String startLimit,
  });

  Future<List<AssignEmployee>> searchEmployees({
    required String logUserId,
    required String search,
  });
}