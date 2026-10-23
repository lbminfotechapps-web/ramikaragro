
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/schedule_list_repository.dart';

import '../datasources/schedule_list_remote_data_source.dart';
import '../models/schedule_list_model.dart';

class ScheduleListRepositoryImpl
    implements ScheduleListRepository {

  final ScheduleListRemoteDataSource remote;

  const ScheduleListRepositoryImpl({
    required this.remote,
  });

  // ================= GET SCHEDULES =================

  @override
  Future<List<ScheduleListEntity>> getSchedules(
    ScheduleListFilter filter,
  ) async {
    final data = await remote.getSchedules(
      filter.toPostData(),
    );

    return data
        .map(
          (json) => ScheduleListModel.fromJson(
            json,
            fallbackFarmerId: filter.farmerId,
          ),
        )
        .toList();
  }

  // ================= SEARCH FARMERS =================

  @override
  Future<List<ScheduleFarmerFilter>> searchFarmers(
    String search,
  ) async {
    final data = await remote.searchFarmers(search);

    return data.map((json) {
      String read(String key) =>
          json[key]?.toString().trim() ?? '';

      return ScheduleFarmerFilter(
        farmerId: read('fld_farmer_id'),
        farmerName: read('fld_farmer_name'),
        talukaName: read('fld_taluka_name'),
      );
    }).where((farmer) {
      return farmer.farmerId.isNotEmpty &&
          farmer.farmerName.isNotEmpty;
    }).toList();
  }

  // ================= DELETE SCHEDULE =================

  @override
  Future<String> deleteSchedule({
    required String scheduleId,
    required String empId,
  }) {
    return remote.deleteSchedule(
      scheduleId: scheduleId,
      empId: empId,
    );
  }

  // ================= UPDATE SCHEDULE =================

  @override
  Future<String> updateScheduleStatus({
    required String scheduleId,
    required String empId,
  }) {
    return remote.updateScheduleStatus(
      scheduleId: scheduleId,
      empId: empId,
    );
  }
}
