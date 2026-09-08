import 'package:demo/features/leave/data/datasources/leave_remote_data_source.dart';

import '../../domain/entities/leave.dart';
import '../../domain/repositories/leave_repository.dart';


class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;

  LeaveRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Leave>> getLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
  }) {
    return remoteDataSource.getLeaveList(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<String> addLeave({
    required String userId,
    required String fromDate,
    required String endDate,
    required String startLeaveType,
    required String endLeaveType,
    required String totalLeaveDays,
    required String reason,
  }) {
    return remoteDataSource.addLeave(
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