import '../entities/leave.dart';

abstract class LeaveRepository {
  Future<List<Leave>> getLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
  });

  Future<String> addLeave({
    required String userId,
    required String fromDate,
    required String endDate,
    required String startLeaveType,
    required String endLeaveType,
    required String totalLeaveDays,
    required String reason,
  });
}