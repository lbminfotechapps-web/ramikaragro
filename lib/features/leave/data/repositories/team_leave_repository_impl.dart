import 'package:demo/core/error/exceptions.dart';
import 'package:demo/features/leave/data/datasources/team_leave_remote_datasource.dart';
import 'package:demo/features/leave/data/models/team_leave_model.dart';
import 'package:demo/features/leave/domain/repositories/team_leave_repository.dart';

class TeamLeaveRepositoryImpl
    implements TeamLeaveRepository {
  final TeamLeaveRemoteDataSource remoteDataSource;

  TeamLeaveRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<TeamLeaveModel>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  }) async {
    try {
      return await remoteDataSource.getTeamLeaveList(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: startLimit,
        searchText: searchText,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        e.toString(),
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  }) async {
    try {
      return await remoteDataSource.updateLeaveStatus(
        leaveId: leaveId,
        userId: userId,
        remark: remark,
        status: status,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        e.toString(),
      );
    }
  }
}