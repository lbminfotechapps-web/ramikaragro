import '../../domain/entities/leave.dart';

class LeaveModel extends Leave {
  const LeaveModel({
    required super.leaveApplicationDate,
    required super.admName,
    required super.fromDate,
    required super.toDate,
    required super.leaveDays,
    required super.status,
    required super.remark,
    required super.reasonForReject,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveApplicationDate:
          json['leaveApplicationDate']?.toString() ??
              json['fld_leave_application_date']?.toString() ??
              '',

      admName:
          json['admName']?.toString() ??
              json['fld_adm_name']?.toString() ??
              '',

      fromDate:
          json['fromDate']?.toString() ??
              json['fld_from_date']?.toString() ??
              '',

      toDate:
          json['toDate']?.toString() ??
              json['fld_to_date']?.toString() ??
              '',

      leaveDays:
          json['leaveDays']?.toString() ??
              json['fld_leave_days']?.toString() ??
              '',

      status:
          json['status']?.toString() ??
              json['fld_status']?.toString() ??
              '0',

      remark:
          json['remark']?.toString() ??
              json['fld_remark']?.toString() ??
              '',

      reasonForReject:
          json['reasonForReject']?.toString() ??
              json['fld_reason_for_reject']?.toString() ??
              '',
    );
  }
}

