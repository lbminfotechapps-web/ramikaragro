import 'package:get_it/get_it.dart';
import 'package:solufine/features/schedule/data/datasources/farmer_schedule_remote_data_source.dart';
import 'package:solufine/features/schedule/data/repositories/farmer_schedule_repository_impl.dart';
import 'package:solufine/features/schedule/domain/repositories/farmer_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/usecases/search_crop.dart';
import 'package:solufine/features/schedule/domain/usecases/search_schedule_farmer.dart';
import 'package:solufine/features/schedule/presentation/bloc/farmer_schedule_bloc.dart';

import '../api_constant/dio_client.dart';



final GetIt sl =
    GetIt.instance;

Future<void>
    initFarmerScheduleDi() async {
  // ============================================================
  // DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<
      FarmerScheduleRemoteDataSource>()) {
    sl.registerLazySingleton<
        FarmerScheduleRemoteDataSource>(
      () =>
          FarmerScheduleRemoteDataSourceImpl(
        dioClient:
            DioClient(),
      ),
    );
  }

  // ============================================================
  // REPOSITORY
  // ============================================================

  if (!sl.isRegistered<
      FarmerScheduleRepository>()) {
    sl.registerLazySingleton<
        FarmerScheduleRepository>(
      () =>
          FarmerScheduleRepositoryImpl(
        remoteDataSource:
            sl<
                FarmerScheduleRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // USE CASES
  // ============================================================

  if (!sl.isRegistered<
      SearchCrop>()) {
    sl.registerLazySingleton<
        SearchCrop>(
      () =>
          SearchCrop(
        sl<
            FarmerScheduleRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<
      SearchScheduleFarmer>()) {
    sl.registerLazySingleton<
        SearchScheduleFarmer>(
      () =>
          SearchScheduleFarmer(
        sl<
            FarmerScheduleRepository>(),
      ),
    );
  }

  // ============================================================
  // BLOC
  // ============================================================

  if (!sl.isRegistered<
      FarmerScheduleBloc>()) {
    sl.registerFactory<
        FarmerScheduleBloc>(
      () =>
          FarmerScheduleBloc(
        searchCrop:
            sl<SearchCrop>(),

        searchFarmer:
            sl<
                SearchScheduleFarmer>(),
      ),
    );
  }
}