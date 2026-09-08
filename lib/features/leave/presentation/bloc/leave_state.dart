import 'package:equatable/equatable.dart';

import '../../domain/entities/leave.dart';

enum LeaveStatus {
  initial,
  loading,
  success,
  failure,
}

enum AddLeaveStatus {
  initial,
  loading,
  success,
  failure,
}

class LeaveState extends Equatable {
  final LeaveStatus leaveStatus;
  final AddLeaveStatus addLeaveStatus;

  final List<Leave> leaves;

  final String? errorMessage;
  final String? successMessage;

  const LeaveState({
    this.leaveStatus = LeaveStatus.initial,
    this.addLeaveStatus = AddLeaveStatus.initial,
    this.leaves = const [],
    this.errorMessage,
    this.successMessage,
  });

  LeaveState copyWith({
    LeaveStatus? leaveStatus,
    AddLeaveStatus? addLeaveStatus,
    List<Leave>? leaves,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return LeaveState(
      leaveStatus:
          leaveStatus ?? this.leaveStatus,

      addLeaveStatus:
          addLeaveStatus ?? this.addLeaveStatus,

      leaves:
          leaves ?? this.leaves,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,

      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        leaveStatus,
        addLeaveStatus,
        leaves,
        errorMessage,
        successMessage,
      ];
}