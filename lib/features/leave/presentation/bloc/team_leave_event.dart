import 'package:equatable/equatable.dart';

abstract class TeamLeaveEvent extends Equatable {
  const TeamLeaveEvent();

  @override
  List<Object?> get props => [];
}

class GetTeamLeaveListEvent extends TeamLeaveEvent {
  final String userId;
  final String fromDate;
  final String toDate;
  final int startLimit;
  final String searchText;

  const GetTeamLeaveListEvent({
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.startLimit,
    required this.searchText,
  });

  @override
  List<Object?> get props => [
        userId,
        fromDate,
        toDate,
        startLimit,
        searchText,
      ];
}

class RefreshTeamLeaveListEvent
    extends TeamLeaveEvent {
  final String userId;
  final String fromDate;
  final String toDate;
  final String searchText;

  const RefreshTeamLeaveListEvent({
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.searchText,
  });

  @override
  List<Object?> get props => [
        userId,
        fromDate,
        toDate,
        searchText,
      ];
}

class UpdateTeamLeaveStatusEvent
    extends TeamLeaveEvent {
  final String leaveId;
  final String userId;
  final String remark;
  final String status;

  const UpdateTeamLeaveStatusEvent({
    required this.leaveId,
    required this.userId,
    required this.remark,
    required this.status,
  });

  @override
  List<Object?> get props => [
        leaveId,
        userId,
        remark,
        status,
      ];
}