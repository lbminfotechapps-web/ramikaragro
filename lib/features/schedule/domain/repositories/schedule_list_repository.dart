
import '../entities/schedule_list_entity.dart';

abstract class ScheduleListRepository {
  Future<List<ScheduleListEntity>> getSchedules(
    ScheduleListFilter filter,
  );

  Future<List<ScheduleFarmerFilter>> searchFarmers(
    String search,
  );
}

class ScheduleFarmerFilter {
  final String farmerId;
  final String farmerName;
  final String talukaName;

  const ScheduleFarmerFilter({
    required this.farmerId,
    required this.farmerName,
    this.talukaName = '',
  });
}
