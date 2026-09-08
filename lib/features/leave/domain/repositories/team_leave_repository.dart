
import 'package:demo/features/leave/domain/entities/team_leave.dart';

abstract class TeamLeaveRepository {
  Future<List<TeamLeave>> getTeamLeaveList({
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