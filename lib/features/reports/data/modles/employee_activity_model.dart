import '../../domain/entities/employee_activity.dart';

class EmployeeActivityModel extends EmployeeActivity {
  const EmployeeActivityModel({
    required super.activityName,
    required super.visitTo,
    required super.dailyTranId,
    required super.farmerName,
    required super.outletName,
    required super.time,
    required super.userId,
    required super.selfieImage,
    required super.adminName,
    required super.adminMobile,
    required super.isMaxVisited,
  });

  factory EmployeeActivityModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmployeeActivityModel(
      activityName:
          json['fld_activity_name']?.toString() ?? '',

      visitTo:
          json['fld_visit_to']?.toString() ?? '',

      dailyTranId:
          json['fld_daily_tran_id']?.toString() ?? '',

      // null → ''
      farmerName:
          json['fld_farmer_name']?.toString() ?? '',

      // null → ''
      outletName:
          json['fld_outlet_name']?.toString() ?? '',

      time:
          json['fld_time']?.toString() ?? '',

      userId:
          json['fld_user_id']?.toString() ?? '',

      selfieImage:
          json['fld_selfie_image']?.toString() ?? '',

      adminName:
          json['fld_adm_name']?.toString() ?? '',

      adminMobile:
          json['admin_mobile']?.toString() ?? '',

      isMaxVisited:
          json['fld_is_max_visited']?.toString() ?? '0',
    );
  }
}