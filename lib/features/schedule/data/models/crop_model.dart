import '../../domain/entities/crop_entity.dart';

class CropModel extends CropEntity {
  const CropModel({
    required super.cropName,
  });

  factory CropModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CropModel(
      cropName:
          json['fld_crop_name']
                  ?.toString() ??
              '',
    );
  }
}