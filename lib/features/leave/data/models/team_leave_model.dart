import 'package:demo/features/leave/domain/entities/team_leave.dart';

class TeamLeaveModel extends TeamLeave {
  const TeamLeaveModel({
    required super.leaveId,
    required super.employeeName,
    required super.reportingStatus,
    required super.managerStatus,
    required super.fromDate,
    required super.toDate,
    required super.leaveDays,
    required super.remark,
    required super.status,
    required super.statusUpdateBy,
    required super.leaveApplicationDate,
    required super.teamRemark,
    required super.adminStatus,
  });

  factory TeamLeaveModel.fromJson(Map<String, dynamic> json) {
    return TeamLeaveModel(
      leaveId: json['fld_leave_id']?.toString() ?? '',
      employeeName: json['fld_adm_name']?.toString() ?? '',
      reportingStatus:
          json['fld_reporting_status']?.toString() ?? '',
      managerStatus:
          json['fld_manager_status']?.toString() ?? '',
      fromDate:
          json['fld_from_date']?.toString() ?? '',
      toDate:
          json['fld_to_date']?.toString() ?? '',
      leaveDays:
          json['fld_leave_days']?.toString() ?? '',
      remark:
          json['fld_remark']?.toString() ?? '',
      status:
          json['fld_status']?.toString() ?? '',
      statusUpdateBy:
          json['fld_status_update_by']?.toString() ?? '',
      leaveApplicationDate:
          json['fld_leave_application_date']?.toString() ?? '',
      teamRemark:
          json['fld_team_remark']?.toString() ?? '',
      adminStatus:
          json['fld_admin_status']?.toString() ?? '',
    );
  }
}