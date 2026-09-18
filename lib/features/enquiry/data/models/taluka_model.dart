import '../../domain/entities/taluka_entity.dart';

class TalukaModel extends TalukaEntity {
  const TalukaModel({
    required super.districtId,
    required super.talukaId,
    required super.name,
  });

  factory TalukaModel.fromJson(Map<String, dynamic> json) {
    return TalukaModel(
      districtId: json['fld_disc_id']?.toString() ?? '',
      talukaId: json['fld_taluka_id']?.toString() ?? '',
      name: json['fld_name']?.toString() ?? '',
    );
  }
}