

import 'package:demo/features/leave/domain/entities/team_leave.dart';
import 'package:demo/features/leave/domain/repositories/team_leave_repository.dart';

class GetTeamLeaveList {
  final TeamLeaveRepository repository;

  GetTeamLeaveList({
    required this.repository,
  });

  Future<List<TeamLeave>> call({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  }) async {
    return await repository.getTeamLeaveList(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
      searchText: searchText,
    );
  }
}