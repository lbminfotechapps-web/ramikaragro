import 'package:solufine/features/home/doman/home_entity/inpunch_pending_entity.dart';

class InpunchPendingResponseModel extends InpunchPendingResponseEntity {
  const InpunchPendingResponseModel({
    required super.status,
    required super.message,
    required super.totalRecursiveEmployee,
    required super.pendingInpunchCount,
    required super.inpunchTime,
    required super.address,
    required super.city,
    required super.state,
    required super.result,
  });

  factory InpunchPendingResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final resultJson = json['result'];

    return InpunchPendingResponseModel(
      status: json['status'] == true,

      message: json['message']?.toString() ?? '',

      totalRecursiveEmployee:
          int.tryParse(
                json['total_recursive_employee']?.toString() ?? '0',
              ) ??
              0,

      pendingInpunchCount:
          int.tryParse(
                json['pending_inpunch_count']?.toString() ?? '0',
              ) ??
              0,

      inpunchTime: json['inpunch_time']?.toString() ?? '',

      address: json['address']?.toString() ?? '',

      city: json['city']?.toString() ?? '',

      state: json['state']?.toString() ?? '',

      result: resultJson is List
          ? resultJson
              .whereType<Map>()
              .map(
                (e) => InpunchPendingModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : [],
    );
  }
}
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
