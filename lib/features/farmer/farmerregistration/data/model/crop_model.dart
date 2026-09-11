

import 'package:demo/features/farmer/farmerregistration/domain/entity/crop_entity.dart';

class CropModel extends CropEntity {
  const CropModel({
    required super.fldCropId,
    required super.fldCropName,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      fldCropId: json['fld_crop_id']?.toString() ?? '',
      fldCropName: json['fld_crop_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_crop_id': fldCropId,
      'fld_crop_name': fldCropName,
    };
  }
}