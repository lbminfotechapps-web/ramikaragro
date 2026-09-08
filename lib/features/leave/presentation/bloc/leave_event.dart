import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class GetLeaveListEvent extends LeaveEvent {
  final String? fromDate;
  final String? toDate;

  const GetLeaveListEvent({
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [
        fromDate,
        toDate,
      ];
}

class AddLeaveEvent extends LeaveEvent {
  final String fromDate;
  final String endDate;
  final String startLeaveType;
  final String endLeaveType;
  final String totalLeaveDays;
  final String reason;

  const AddLeaveEvent({
    required this.fromDate,
    required this.endDate,
    required this.startLeaveType,
    required this.endLeaveType,
    required this.totalLeaveDays,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        fromDate,
        endDate,
        startLeaveType,
        endLeaveType,
        totalLeaveDays,
        reason,
      ];
}

class ClearLeaveMessageEvent extends LeaveEvent {
  const ClearLeaveMessageEvent();
}