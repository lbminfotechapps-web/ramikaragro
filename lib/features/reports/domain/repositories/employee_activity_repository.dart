import '../entities/employee_activity.dart';

abstract class EmployeeActivityRepository {
  Future<List<EmployeeActivity>>
      getEmployeeActivityDetails({
    required String userId,
    required String searchDate,
    required String logUserId,
  });
}