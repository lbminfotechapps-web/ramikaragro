

import 'package:demo/features/home/data/home_datasource/crop_schedule_remote_data_source.dart';
import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';
import 'package:demo/features/home/doman/home_repository/crop_schedule_repository.dart';

class CropScheduleRepositoryImpl
    implements CropScheduleRepository {
  final CropScheduleRemoteDataSource remoteDataSource;

  CropScheduleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CropSchedule>> getCropSchedules() {
    return remoteDataSource.getCropSchedules();
  }
}