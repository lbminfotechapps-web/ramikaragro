import 'package:equatable/equatable.dart';

import '../../domain/entities/team_leave.dart';

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
  // ==========================================================
  // LIST
  // ==========================================================

  final TeamLeaveStatus status;
  final List<TeamLeave> leaves;
  final String? errorMessage;

  // ==========================================================
  // UPDATE
  // ==========================================================

  final UpdateLeaveStatus updateStatus;
  final String? updateMessage;

  // Leave ID currently being updated
  final String? updatingLeaveId;

  const TeamLeaveState({
    this.status = TeamLeaveStatus.initial,
    this.leaves = const [],
    this.errorMessage,
    this.updateStatus = UpdateLeaveStatus.initial,
    this.updateMessage,
    this.updatingLeaveId,
  });

  TeamLeaveState copyWith({
    TeamLeaveStatus? status,
    List<TeamLeave>? leaves,
    String? errorMessage,
    UpdateLeaveStatus? updateStatus,
    String? updateMessage,
    String? updatingLeaveId,
    bool clearError = false,
    bool clearUpdateMessage = false,
    bool clearUpdatingLeaveId = false,
  }) {
    return TeamLeaveState(
      status: status ?? this.status,
      leaves: leaves ?? this.leaves,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,

      updateStatus:
          updateStatus ?? this.updateStatus,

      updateMessage: clearUpdateMessage
          ? null
          : updateMessage ?? this.updateMessage,

      updatingLeaveId: clearUpdatingLeaveId
          ? null
          : updatingLeaveId ?? this.updatingLeaveId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        leaves,
        errorMessage,
        updateStatus,
        updateMessage,
        updatingLeaveId,
      ];
}