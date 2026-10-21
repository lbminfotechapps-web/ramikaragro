
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/plot_registration/data/datasources/plot_remote_data_source.dart';
import 'package:solufine/features/plot_registration/data/repositories/plot_repository_impl.dart';
import 'package:solufine/features/plot_registration/domain/repositories/plot_repository.dart';
import 'package:solufine/features/plot_registration/domain/usecases/plot_usecases.dart';
import 'package:solufine/features/plot_registration/presentation/bloc/plot_bloc.dart';

final sl = GetIt.instance;

Future<void> initPlotRegistrationDi() async {
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(() => DioClient());
  }

  if (!sl.isRegistered<PlotRemoteDataSource>()) {
    sl.registerLazySingleton<PlotRemoteDataSource>(
      () => PlotRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  if (!sl.isRegistered<PlotRepository>()) {
    sl.registerLazySingleton<PlotRepository>(
      () => PlotRepositoryImpl(
        remote: sl<PlotRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchPlotFarmers>()) {
    sl.registerLazySingleton<SearchPlotFarmers>(
      () => SearchPlotFarmers(sl<PlotRepository>()),
    );
  }

  if (!sl.isRegistered<GetPlotCrops>()) {
    sl.registerLazySingleton<GetPlotCrops>(
      () => GetPlotCrops(sl<PlotRepository>()),
    );
  }

  if (!sl.isRegistered<SubmitPlotRegistration>()) {
    sl.registerLazySingleton<SubmitPlotRegistration>(
      () => SubmitPlotRegistration(
        sl<PlotRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<PlotBloc>()) {
    sl.registerFactory<PlotBloc>(
      () => PlotBloc(
        searchFarmers: sl<SearchPlotFarmers>(),
        getCrops: sl<GetPlotCrops>(),
        submitPlotRegistration:
            sl<SubmitPlotRegistration>(),
      ),
    );
  }
}
