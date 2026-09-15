import 'package:demo/features/home/doman/home_entity/inpunch_pending_entity.dart';

class InpunchPendingModel extends InpunchPendingEntity {
  const InpunchPendingModel({
    super.fldAdmName,
    super.fldReportingPerson,
    super.fldMobileNo,
  });

  factory InpunchPendingModel.fromJson(Map<String, dynamic> json) {
    return InpunchPendingModel(
      fldAdmName: json['fld_adm_name']?.toString(),
      fldReportingPerson: json['fld_reporting_person']?.toString(),
      fldMobileNo: json['fld_mobile_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_adm_name': fldAdmName,
      'fld_reporting_person': fldReportingPerson,
      'fld_mobile_no': fldMobileNo,
    };
  }
}
