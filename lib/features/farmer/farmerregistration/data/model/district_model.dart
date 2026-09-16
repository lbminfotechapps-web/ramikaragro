import 'package:demo/features/farmer/farmerregistration/data/model/talukha_model.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.fldDistId,
    required super.fldDistName,
    required super.taluka,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      fldDistId: json['fld_dist_id']?.toString() ?? '',
      fldDistName: json['fld_dist_name']?.toString() ?? '',
      taluka: (json['taluka'] as List<dynamic>? ?? [])
          .map((item) => TalukaModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_dist_id': fldDistId,
      'fld_dist_name': fldDistName,
      'taluka': taluka
          .map(
            (item) => TalukaModel(
              fldDiscId: item.fldDiscId,
              fldTalukaId: item.fldTalukaId,
              fldName: item.fldName,
            ).toJson(),
          )
          .toList(),
    };
  }
}
