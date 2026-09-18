import '../../domain/entities/followup_entity.dart';

class FollowupModel extends FollowupEntity {
  const FollowupModel({
    required super.name,
    required super.type,
    required super.date,
    required super.time,
    required super.remark,
    required super.followupType,
    required super.followupDate,
    required super.outletId,
    required super.farmerId,
    required super.mobileNo,
  });

  factory FollowupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FollowupModel(
      name: json['fld_name']?.toString() ?? '',
      type: json['fld_type']?.toString() ?? '',
      date: json['fld_date']?.toString() ?? '',
      time: json['fld_time']?.toString() ?? '',
      remark: json['fld_remark']?.toString() ?? '',
      followupType:json['fld_followup_type']?.toString() ?? '',
      followupDate:json['fld_followup_date']?.toString() ?? '',
      outletId:json['fld_outlet_id']?.toString() ?? '',
      farmerId:json['fld_farmer_id']?.toString() ?? '',
       mobileNo:json['fld_mobile_no']?.toString() ?? '',
    );
  }
}