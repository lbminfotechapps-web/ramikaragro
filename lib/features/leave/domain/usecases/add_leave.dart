import '../repositories/leave_repository.dart';

class AddLeave {
  final LeaveRepository repository;

  AddLeave(this.repository);

  Future<String> call({
    required String userId,
    required String fromDate,
    required String endDate,
    required String startLeaveType,
    required String endLeaveType,
    required String totalLeaveDays,
    required String reason,
  }) {
    return repository.addLeave(
      userId: userId,
      fromDate: fromDate,
      endDate: endDate,
      startLeaveType: startLeaveType,
      endLeaveType: endLeaveType,
      totalLeaveDays: totalLeaveDays,
      reason: reason,
    );
  }
}