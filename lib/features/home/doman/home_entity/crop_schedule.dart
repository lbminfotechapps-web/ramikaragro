import 'crop_schedule_detail.dart';

class CropSchedule {
  final String cropId;
  final String cropName;
  final String attachment;
  final List<CropScheduleDetail> details;

  const CropSchedule({
    required this.cropId,
    required this.cropName,
    required this.attachment,
    required this.details,
  });
}