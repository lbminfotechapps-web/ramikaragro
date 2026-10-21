
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';

import 'package:solufine/features/schedule/data/datasources/farmer_schedule_remote_data_source.dart';
import 'package:solufine/features/schedule/data/datasources/farmer_plot_remote_data_source.dart';

import 'package:solufine/features/schedule/data/repositories/farmer_schedule_repository_impl.dart';
import 'package:solufine/features/schedule/data/repositories/farmer_plot_repository_impl.dart';

import 'package:solufine/features/schedule/domain/repositories/farmer_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/repositories/farmer_plot_repository.dart';

import 'package:solufine/features/schedule/domain/usecases/search_crop.dart';
import 'package:solufine/features/schedule/domain/usecases/search_schedule_farmer.dart';
import 'package:solufine/features/schedule/domain/usecases/get_farmer_plots.dart';

import 'package:solufine/features/schedule/presentation/bloc/farmer_schedule_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initFarmerScheduleDi() async {
  // ============================================================
  // CORE
  // ============================================================

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ============================================================
  // EXISTING FARMER + CROP DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<FarmerScheduleRemoteDataSource>()) {
    sl.registerLazySingleton<FarmerScheduleRemoteDataSource>(
      () => FarmerScheduleRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ============================================================
  // NEW FARMER PLOT DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<FarmerPlotRemoteDataSource>()) {
    sl.registerLazySingleton<FarmerPlotRemoteDataSource>(
      () => FarmerPlotRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ============================================================
  // EXISTING FARMER + CROP REPOSITORY
  // ============================================================

  if (!sl.isRegistered<FarmerScheduleRepository>()) {
    sl.registerLazySingleton<FarmerScheduleRepository>(
      () => FarmerScheduleRepositoryImpl(
        remoteDataSource:
            sl<FarmerScheduleRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // NEW FARMER PLOT REPOSITORY
  // ============================================================

  if (!sl.isRegistered<FarmerPlotRepository>()) {
    sl.registerLazySingleton<FarmerPlotRepository>(
      () => FarmerPlotRepositoryImpl(
        remoteDataSource:
            sl<FarmerPlotRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // EXISTING USE CASES
  // ============================================================

  if (!sl.isRegistered<SearchCrop>()) {
    sl.registerLazySingleton<SearchCrop>(
      () => SearchCrop(
        sl<FarmerScheduleRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchScheduleFarmer>()) {
    sl.registerLazySingleton<SearchScheduleFarmer>(
      () => SearchScheduleFarmer(
        sl<FarmerScheduleRepository>(),
      ),
    );
  }

  // ============================================================
  // NEW GET FARMER PLOTS USE CASE
  // ============================================================

  if (!sl.isRegistered<GetFarmerPlots>()) {
    sl.registerLazySingleton<GetFarmerPlots>(
      () => GetFarmerPlots(
        sl<FarmerPlotRepository>(),
      ),
    );
  }

  // ============================================================
  // FARMER SCHEDULE BLOC
  // ============================================================

  if (!sl.isRegistered<FarmerScheduleBloc>()) {
    sl.registerFactory<FarmerScheduleBloc>(
      () => FarmerScheduleBloc(
        searchCrop: sl<SearchCrop>(),
        searchFarmer: sl<SearchScheduleFarmer>(),
        getFarmerPlots: sl<GetFarmerPlots>(),
      ),
    );
  }
}
