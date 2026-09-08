import 'package:demo/features/leave/domain/entities/team_leave.dart';
import 'package:equatable/equatable.dart';



enum TeamLeaveStatus {
  initial,
  loading,
  success,
  failure,
}

enum UpdateLeaveStatus {
  initial,
  loading,
  success,
  failure,
}

class TeamLeaveState extends Equatable {
  final TeamLeaveStatus status;
  final List<TeamLeave> leaves;
  final String? errorMessage;

  final UpdateLeaveStatus updateStatus;
  final String? updateMessage;

  const TeamLeaveState({
    this.status = TeamLeaveStatus.initial,
    this.leaves = const [],
    this.errorMessage,
    this.updateStatus = UpdateLeaveStatus.initial,
    this.updateMessage,
  });

  TeamLeaveState copyWith({
    TeamLeaveStatus? status,
    List<TeamLeave>? leaves,
    String? errorMessage,
    UpdateLeaveStatus? updateStatus,
    String? updateMessage,
  }) {
    return TeamLeaveState(
      status: status ?? this.status,
      leaves: leaves ?? this.leaves,
      errorMessage: errorMessage,
      updateStatus:
          updateStatus ?? this.updateStatus,
      updateMessage: updateMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        leaves,
        errorMessage,
        updateStatus,
        updateMessage,
      ];
}