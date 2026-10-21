import '../../domain/entities/crop_entity.dart';

class CropModel extends CropEntity {
  const CropModel({required super.cropName, super.cropId});

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      cropId: json['fld_crop_id']?.toString().trim() ?? '',
      cropName: json['fld_crop_name']?.toString() ?? '',
    );
  }
}
