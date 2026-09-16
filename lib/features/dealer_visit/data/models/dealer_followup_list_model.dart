import 'package:demo/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';

class DealerFollowupListModel extends DealerFollowupListEntity {
  const DealerFollowupListModel({
    required super.admName,
    required super.outletName,
    required super.followupDate,
    required super.followupTime,
    required super.followupRemark,
  });

  factory DealerFollowupListModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DealerFollowupListModel(
      admName: json['fld_adm_name']?.toString() ?? '',
      outletName: json['fld_outlet_name']?.toString() ?? '',
      followupDate: json['fld_date']?.toString() ?? '',
      followupTime: json['fld_time']?.toString() ?? '',
      followupRemark: json['fld_remark']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_adm_name': admName,
      'fld_outlet_name': outletName,
      'fld_date': followupDate,
      'fld_time': followupTime,
      'fld_remark': followupRemark,
    };
  }
}