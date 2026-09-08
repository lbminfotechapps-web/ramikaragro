import '../../domain/entities/leave.dart';

class LeaveModel extends Leave {
  const LeaveModel({
    required super.leaveApplicationDate,
    required super.admName,
    required super.status,
    required super.fromDate,
    required super.toDate,
    required super.leaveDays,
    required super.remark,
    required super.reasonForReject,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveApplicationDate:
          json['fld_leave_application_date']?.toString() ?? '',

      admName:
          json['fld_adm_name']?.toString() ?? '',

      status:
          json['fld_status']?.toString() ?? '',

      fromDate:
          json['fld_from_date']?.toString() ?? '',

      toDate:
          json['fld_to_date']?.toString() ?? '',

      leaveDays:
          json['fld_leave_days']?.toString() ?? '',

      remark:
          json['fld_remark']?.toString() ?? '',

      reasonForReject:
          json['fld_reason_for_reject']?.toString() ?? '',
    );
  }
}