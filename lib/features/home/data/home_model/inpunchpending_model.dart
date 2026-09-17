import 'package:demo/features/home/doman/home_entity/inpunch_pending_entity.dart';

class InpunchPendingResponseModel extends InpunchPendingResponseEntity {
  const InpunchPendingResponseModel({
    required super.status,
    super.message,
    required super.totalRecursiveEmployee,
    required super.pendingInpunchCount,
    super.inpunchTime,
    super.address,
    super.city,
    super.state,
    required super.result,
  });

  factory InpunchPendingResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];

    return InpunchPendingResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      totalRecursiveEmployee:
          int.tryParse(json['total_recursive_employee']?.toString() ?? '') ?? 0,
      pendingInpunchCount:
          int.tryParse(json['pending_inpunch_count']?.toString() ?? '') ?? 0,
      inpunchTime: json['inpunch_time']?.toString()?? '',
      address: json['address']?.toString()?? '',
      city: json['city']?.toString()?? '',
      state: json['state']?.toString()?? '',
      result: result is List
          ? result
                .whereType<Map>()
                .map(
                  (item) => InpunchPendingModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <InpunchPendingModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'total_recursive_employee': totalRecursiveEmployee,
      'pending_inpunch_count': pendingInpunchCount,
      'inpunch_time': inpunchTime,
      'address': address,
      'result': result
          .map(
            (item) => {
              'fld_adm_name': item.fldAdmName,
              'fld_reporting_person': item.fldReportingPerson,
              'fld_mobile_no': item.fldMobileNo,
            },
          )
          .toList(),
    };
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
