

import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';
import 'package:demo/features/home/doman/home_repository/crop_schedule_repository.dart';

class GetCropSchedules {
  final CropScheduleRepository repository;

  GetCropSchedules({
    required this.repository,
  });

  Future<List<CropSchedule>> call() {
    return repository.getCropSchedules();
  }
}