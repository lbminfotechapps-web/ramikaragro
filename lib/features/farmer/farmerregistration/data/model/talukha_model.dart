import 'package:demo/features/farmer/farmerregistration/domain/entity/taluka_entity.dart';

class TalukaModel extends TalukaEntity {
  const TalukaModel({
    required super.fldDiscId,
    required super.fldTalukaId,
    required super.fldName,
  });

  factory TalukaModel.fromJson(Map<String, dynamic> json) {
    return TalukaModel(
      fldDiscId: json['fld_disc_id']?.toString() ?? '',
      fldTalukaId: json['fld_taluka_id']?.toString() ?? '',
      fldName: json['fld_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_disc_id': fldDiscId,
      'fld_taluka_id': fldTalukaId,
      'fld_name': fldName,
    };
  }
}
