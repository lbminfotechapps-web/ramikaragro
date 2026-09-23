import 'package:equatable/equatable.dart';

class Leave extends Equatable {
  final String leaveApplicationDate;
  final String admName;
  final String status;
  final String fromDate;
  final String toDate;
  final String leaveDays;
  final String remark;
  final String reasonForReject;
  final String rejectStatus;
  final String adminStatus;

  const Leave({
    required this.leaveApplicationDate,
    required this.admName,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.leaveDays,
    required this.remark,
    required this.reasonForReject,
    required this.rejectStatus,
    required this.adminStatus,
  });

  @override
  List<Object?> get props => [
        leaveApplicationDate,
        admName,
        status,
        fromDate,
        toDate,
        leaveDays,
        remark,
        reasonForReject,
        rejectStatus,
        adminStatus,
      ];
}