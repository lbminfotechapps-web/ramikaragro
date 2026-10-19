import '../entities/schedule_farmer_entity.dart';
import '../repositories/farmer_schedule_repository.dart';

class SearchScheduleFarmer {
  final FarmerScheduleRepository repository;

  SearchScheduleFarmer(
    this.repository,
  );

  Future<List<ScheduleFarmerEntity>>
      call({
    required String searchKey,
  }) {
    return repository.searchFarmer(
      searchKey:
          searchKey,
    );
  }
}