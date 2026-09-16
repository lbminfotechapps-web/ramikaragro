
import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';

abstract class CropScheduleRepository {
  Future<List<CropSchedule>> getCropSchedules();
}