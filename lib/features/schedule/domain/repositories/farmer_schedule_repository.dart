import '../entities/crop_entity.dart';
import '../entities/schedule_farmer_entity.dart';

abstract class FarmerScheduleRepository {
  Future<List<CropEntity>> searchCrop({
    required String searchKey,
  });

  Future<List<ScheduleFarmerEntity>>
      searchFarmer({
    required String searchKey,
  });
}