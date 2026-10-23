
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';

// ============================================================
// EXISTING DATA SOURCES
// ============================================================

import 'package:solufine/features/schedule/data/datasources/farmer_schedule_remote_data_source.dart';
import 'package:solufine/features/schedule/data/datasources/farmer_plot_remote_data_source.dart';
import 'package:solufine/features/schedule/data/datasources/plot_schedule_remote_datasource.dart';

// ============================================================
// EXISTING REPOSITORY IMPLEMENTATIONS
// ============================================================

import 'package:solufine/features/schedule/data/repositories/farmer_schedule_repository_impl.dart';
import 'package:solufine/features/schedule/data/repositories/farmer_plot_repository_impl.dart';
import 'package:solufine/features/schedule/data/repositories/plot_schedule_repository_impl.dart';

// ============================================================
// EXISTING REPOSITORY INTERFACES
// ============================================================

import 'package:solufine/features/schedule/domain/repositories/farmer_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/repositories/farmer_plot_repository.dart';
import 'package:solufine/features/schedule/domain/repositories/plot_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/usecases/get_plot_schedule_history.dart';

// ============================================================
// EXISTING USE CASES
// ============================================================

import 'package:solufine/features/schedule/domain/usecases/search_crop.dart';
import 'package:solufine/features/schedule/domain/usecases/search_schedule_farmer.dart';
import 'package:solufine/features/schedule/domain/usecases/get_farmer_plots.dart';

// ============================================================
// EXISTING BLOC
// ============================================================

import 'package:solufine/features/schedule/presentation/bloc/farmer_schedule_bloc.dart';
import 'package:solufine/features/schedule/presentation/bloc/plot_schedule_bloc.dart';

// ============================================================
// NEW PLOT SCHEDULE HISTORY IMPORTS
// ============================================================


final GetIt sl = GetIt.instance;

Future<void> initFarmerSchedulePlotDi() async {

  // ============================================================
  // 1. CORE - DIO CLIENT
  // ============================================================

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ============================================================
  // 2. FARMER + CROP DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<FarmerScheduleRemoteDataSource>()) {
    sl.registerLazySingleton<FarmerScheduleRemoteDataSource>(
      () => FarmerScheduleRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ============================================================
  // 3. FARMER PLOT DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<FarmerPlotRemoteDataSource>()) {
    sl.registerLazySingleton<FarmerPlotRemoteDataSource>(
      () => FarmerPlotRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ============================================================
  // 4. FARMER + CROP REPOSITORY
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
  // 5. FARMER PLOT REPOSITORY
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
  // 6. EXISTING USE CASES
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

  if (!sl.isRegistered<GetFarmerPlots>()) {
    sl.registerLazySingleton<GetFarmerPlots>(
      () => GetFarmerPlots(
        sl<FarmerPlotRepository>(),
      ),
    );
  }

  // ============================================================
  // 7. EXISTING FARMER SCHEDULE BLOC
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

  // ============================================================
  // 8. NEW PLOT SCHEDULE HISTORY DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<PlotScheduleRemoteDataSource>()) {
    sl.registerLazySingleton<PlotScheduleRemoteDataSource>(
      () => PlotScheduleRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }

  // ============================================================
  // 9. NEW PLOT SCHEDULE HISTORY REPOSITORY
  // ============================================================

  if (!sl.isRegistered<PlotScheduleRepository>()) {
    sl.registerLazySingleton<PlotScheduleRepository>(
      () => PlotScheduleRepositoryImpl(
        sl<PlotScheduleRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // 10. NEW PLOT SCHEDULE HISTORY USE CASE
  // ============================================================

  if (!sl.isRegistered<GetPlotScheduleHistory>()) {
    sl.registerLazySingleton<GetPlotScheduleHistory>(
      () => GetPlotScheduleHistory(
        sl<PlotScheduleRepository>(),
      ),
    );
  }

  // ============================================================
  // 11. NEW PLOT SCHEDULE HISTORY BLOC
  // ============================================================

  if (!sl.isRegistered<PlotScheduleBloc>()) {
    sl.registerFactory<PlotScheduleBloc>(
      () => PlotScheduleBloc(
        sl<GetPlotScheduleHistory>(),
      ),
    );
  }
}
