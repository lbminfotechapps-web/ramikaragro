import '../../domain/entities/crop_entity.dart';
import '../../domain/entities/schedule_farmer_entity.dart';
import '../../domain/repositories/farmer_schedule_repository.dart';

import '../datasources/farmer_schedule_remote_data_source.dart';

class FarmerScheduleRepositoryImpl
    implements FarmerScheduleRepository {
  final FarmerScheduleRemoteDataSource
      remoteDataSource;

  FarmerScheduleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CropEntity>> searchCrop({
    required String searchKey,
  }) {
    return remoteDataSource.searchCrop(
      searchKey:
          searchKey,
    );
  }

  @override
  Future<List<ScheduleFarmerEntity>>
      searchFarmer({
    required String searchKey,
  }) {
    return remoteDataSource.searchFarmer(
      searchKey:
          searchKey,
    );
  }
}