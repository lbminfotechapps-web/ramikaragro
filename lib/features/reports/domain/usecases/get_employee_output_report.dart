import '../entities/employee_output_report.dart';
import '../repositories/employee_output_repository.dart';

class GetEmployeeOutputReport {
  final EmployeeOutputRepository repository;

  GetEmployeeOutputReport(
    this.repository,
  );

  Future<List<EmployeeOutputReport>> call({
    required String userId,
    required String employeeId,
    required String fromDate,
    required String toDate,
    required String employeeName,
    required String startLimit,
  }) {
    return repository.getEmployeeOutputReport(
      userId: userId,
      employeeId: employeeId,
      fromDate: fromDate,
      toDate: toDate,
      employeeName: employeeName,
      startLimit: startLimit,
    );
  }
}