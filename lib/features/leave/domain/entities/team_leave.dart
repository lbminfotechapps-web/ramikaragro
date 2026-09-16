
import 'package:equatable/equatable.dart';

class TeamLeave extends Equatable {
  final String leaveId;
  final String employeeName;
  final String reportingStatus;
  final String managerStatus;
  final String fromDate;
  final String toDate;
  final String leaveDays;
  final String remark;
  final String status;
  final String statusUpdateBy;
  final String leaveApplicationDate;
  final String teamRemark;
  final String adminStatus;

  const TeamLeave({
    required this.leaveId,
    required this.employeeName,
    required this.reportingStatus,
    required this.managerStatus,
    required this.fromDate,
    required this.toDate,
    required this.leaveDays,
    required this.remark,
    required this.status,
    required this.statusUpdateBy,
    required this.leaveApplicationDate,
    required this.teamRemark,
    required this.adminStatus,
  });

  TeamLeave copyWith({
    String? leaveId,
    String? employeeName,
    String? reportingStatus,
    String? managerStatus,
    String? fromDate,
    String? toDate,
    String? leaveDays,
    String? remark,
    String? status,
    String? statusUpdateBy,
    String? leaveApplicationDate,
    String? teamRemark,
    String? adminStatus,
  }) {
    return TeamLeave(
      leaveId: leaveId ?? this.leaveId,
      employeeName: employeeName ?? this.employeeName,
      reportingStatus: reportingStatus ?? this.reportingStatus,
      managerStatus: managerStatus ?? this.managerStatus,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      leaveDays: leaveDays ?? this.leaveDays,
      remark: remark ?? this.remark,
      status: status ?? this.status,
      statusUpdateBy: statusUpdateBy ?? this.statusUpdateBy,
      leaveApplicationDate:
          leaveApplicationDate ?? this.leaveApplicationDate,
      teamRemark: teamRemark ?? this.teamRemark,
      adminStatus: adminStatus ?? this.adminStatus,
    );
  }

  @override
  List<Object?> get props => [
        leaveId,
        employeeName,
        reportingStatus,
        managerStatus,
        fromDate,
        toDate,
        leaveDays,
        remark,
        status,
        statusUpdateBy,
        leaveApplicationDate,
        teamRemark,
        adminStatus,
      ];
}

