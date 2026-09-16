
import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';

import 'crop_schedule_detail_model.dart';

class CropScheduleModel extends CropSchedule {
  const CropScheduleModel({
    required super.cropId,
    required super.cropName,
    required super.attachment,
    required super.details,
  });

  factory CropScheduleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic detailsJson = json['details'];

    final List<CropScheduleDetailModel> details = [];

    if (detailsJson is List) {
      for (final item in detailsJson) {
        if (item is Map) {
          details.add(
            CropScheduleDetailModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return CropScheduleModel(
      cropId:
          json['fld_crop_id']?.toString().trim() ?? '',

      cropName:
          json['fld_crop_name']?.toString().trim() ?? '',

      attachment:
          json['fld_attachment']?.toString().trim() ?? '',

      details: details,
    );
  }
}