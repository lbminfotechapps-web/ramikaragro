import 'package:demo/features/scheme/domain/entity/scheme_entity.dart';

class SchemeResponseModel extends SchemeEntity {
  const SchemeResponseModel({
    super.fldImage,
    super.fldRemark,
    super.fldFromDate,
    super.fldToDate,
    super.fldOutletName,
  });

  factory SchemeResponseModel.fromJson(Map<String, dynamic> json) {
    return SchemeResponseModel(
      fldImage: json['fld_image']?.toString(),
      fldRemark: json['fld_remark']?.toString(),
      fldFromDate: json['fld_from_date']?.toString(),
      fldToDate: json['fld_to_date']?.toString(),
      fldOutletName: json['fld_outlet_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_image': fldImage,
      'fld_remark': fldRemark,
      'fld_from_date': fldFromDate,
      'fld_to_date': fldToDate,
      'fld_outlet_name': fldOutletName,
    };
  }
}
