

import 'package:demo/features/home/doman/home_entity/crop_schedule_detail.dart';

class CropScheduleDetailModel extends CropScheduleDetail {
  const CropScheduleDetailModel({
    required super.attachment,
    required super.description,
    required super.scheduleDetailId,
    required super.scheduleId,
    required super.imageName,
    required super.sequenceNo,
  });

  factory CropScheduleDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CropScheduleDetailModel(
      attachment:
          json['fld_attachment']?.toString().trim() ?? '',

      description:
          json['fld_description']?.toString().trim() ?? '',

      scheduleDetailId:
          json['fld_crop_schedule_detail_id']
                  ?.toString()
                  .trim() ??
              '',

      scheduleId:
          json['fld_crop_schedule_id']
                  ?.toString()
                  .trim() ??
              '',

      imageName:
          json['fld_crop_schedule_detail_image_name']
                  ?.toString()
                  .trim() ??
              '',

      sequenceNo:
          json['fld_sequence_no']?.toString().trim() ?? '',
    );
  }
}