import '../entities/employee_activity.dart';
import '../repositories/employee_activity_repository.dart';

class GetEmployeeActivityDetails {
  final EmployeeActivityRepository repository;

  GetEmployeeActivityDetails(
    this.repository,
  );

  Future<List<EmployeeActivity>> call({
    required String userId,
    required String searchDate,
    required String logUserId,
  }) {
    return repository.getEmployeeActivityDetails(
      userId: userId,
      searchDate: searchDate,
      logUserId: logUserId,
    );
  }
}