import '../entities/crop_entity.dart';
import '../repositories/farmer_schedule_repository.dart';

class SearchCrop {
  final FarmerScheduleRepository repository;

  SearchCrop(
    this.repository,
  );

  Future<List<CropEntity>> call({
    required String searchKey,
  }) {
    return repository.searchCrop(
      searchKey:
          searchKey,
    );
  }
}