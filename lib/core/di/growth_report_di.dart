import 'package:get_it/get_it.dart';

import '../api_constant/dio_client.dart';

import '../../features/growth_report/data/datasources/growth_report_remote_datasource.dart';

import '../../features/growth_report/data/repositories/growth_report_repository_impl.dart';

import '../../features/growth_report/domain/repositories/growth_report_repository.dart';

import '../../features/growth_report/domain/usecases/get_growth_report_usecase.dart';

import '../../features/growth_report/domain/usecases/search_growth_dealers_usecase.dart';

import '../../features/growth_report/presentation/bloc/growth_report_bloc.dart';

final GetIt sl =
    GetIt.instance;

Future<void>
    initGrowthReportDi() async {
  // ==========================================================
  // DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<
      GrowthReportRemoteDataSource>()) {
    sl.registerLazySingleton<
        GrowthReportRemoteDataSource>(
      () =>
          GrowthReportRemoteDataSourceImpl(
        dioClient:
            DioClient(),
      ),
    );
  }

  // ==========================================================
  // REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<
      GrowthReportRepository>()) {
    sl.registerLazySingleton<
        GrowthReportRepository>(
      () =>
          GrowthReportRepositoryImpl(
        remoteDataSource:
            sl<
                GrowthReportRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // GROWTH USE CASE
  // ==========================================================

  if (!sl.isRegistered<
      GetGrowthReportUseCase>()) {
    sl.registerLazySingleton<
        GetGrowthReportUseCase>(
      () =>
          GetGrowthReportUseCase(
        sl<
            GrowthReportRepository>(),
      ),
    );
  }

  // ==========================================================
  // DEALER SEARCH USE CASE
  // ==========================================================

  if (!sl.isRegistered<
      SearchGrowthDealersUseCase>()) {
    sl.registerLazySingleton<
        SearchGrowthDealersUseCase>(
      () =>
          SearchGrowthDealersUseCase(
        sl<
            GrowthReportRepository>(),
      ),
    );
  }

  // ==========================================================
  // BLOC
  // ==========================================================

  if (!sl.isRegistered<
      GrowthReportBloc>()) {
    sl.registerFactory<
        GrowthReportBloc>(
      () =>
          GrowthReportBloc(
        getGrowthReportUseCase:
            sl<
                GetGrowthReportUseCase>(),

        searchGrowthDealersUseCase:
            sl<
                SearchGrowthDealersUseCase>(),
      ),
    );
  }
}