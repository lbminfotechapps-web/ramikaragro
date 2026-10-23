
import 'package:http/http.dart';

import '../entities/schedule_list_entity.dart';

abstract class ScheduleListRepository {
  Future<String> deleteSchedule({required String scheduleId, required String empId});

  Future<List<ScheduleListEntity>> getSchedules(
    ScheduleListFilter filter,
  );

  Future<List<ScheduleFarmerFilter>> searchFarmers(
    String search,
  );

  Future<String> updateScheduleStatus({
  required String scheduleId,
  required String empId,
});
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
