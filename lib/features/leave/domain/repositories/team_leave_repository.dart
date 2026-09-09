import '../../data/models/team_leave_model.dart';

abstract class TeamLeaveRepository {
  Future<List<TeamLeaveModel>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  });

  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  });
}