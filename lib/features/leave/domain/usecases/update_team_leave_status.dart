
import 'package:demo/features/leave/domain/repositories/team_leave_repository.dart';

class UpdateTeamLeaveStatus {
  final TeamLeaveRepository repository;

  UpdateTeamLeaveStatus({
    required this.repository,
  });

  Future<Map<String, dynamic>> call({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  }) async {
    return await repository.updateLeaveStatus(
      leaveId: leaveId,
      userId: userId,
      remark: remark,
      status: status,
    );
  }
}