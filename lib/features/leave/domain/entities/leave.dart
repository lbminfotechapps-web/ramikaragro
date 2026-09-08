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

  const Leave({
    required this.leaveApplicationDate,
    required this.admName,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.leaveDays,
    required this.remark,
    required this.reasonForReject,
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
      ];
}