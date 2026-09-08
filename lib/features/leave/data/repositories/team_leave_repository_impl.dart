

import 'package:demo/features/leave/data/datasources/team_leave_remote_datasource.dart';
import 'package:demo/features/leave/domain/entities/team_leave.dart';
import 'package:demo/features/leave/domain/repositories/team_leave_repository.dart';

class TeamLeaveRepositoryImpl
    implements TeamLeaveRepository {
  final TeamLeaveRemoteDataSource remoteDataSource;

  TeamLeaveRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<TeamLeave>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  }) async {
    return await remoteDataSource.getTeamLeaveList(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
      searchText: searchText,
    );
  }

  @override
  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  }) async {
    return await remoteDataSource.updateLeaveStatus(
      leaveId: leaveId,
      userId: userId,
      remark: remark,
      status: status,
    );
  }
}