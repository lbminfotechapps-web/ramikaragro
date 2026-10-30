import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/marketing/other_activity_near_dealer/data/datasources/dealer_activity_remote_data_source.dart';
import 'package:solufine/features/marketing/other_activity_near_dealer/data/repositories/dealer_activity_repository_impl.dart';
import 'package:solufine/features/marketing/other_activity_near_dealer/domain/repositories/dealer_activity_repository.dart';
import 'package:solufine/features/marketing/other_activity_near_dealer/domain/usecases/submit_dealer_activity.dart';
import 'package:solufine/features/marketing/other_activity_near_dealer/presentation/bloc/dealer_activity_bloc.dart';



final sl = GetIt.instance;

Future<void> initDealerActivityDi() async {
  // DIO CLIENT
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // DATA SOURCE
  if (!sl.isRegistered<DealerActivityRemoteDataSource>()) {
    sl.registerLazySingleton<DealerActivityRemoteDataSource>(
      () => DealerActivityRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }

  // REPOSITORY
  if (!sl.isRegistered<DealerActivityRepository>()) {
    sl.registerLazySingleton<DealerActivityRepository>(
      () => DealerActivityRepositoryImpl(
        sl<DealerActivityRemoteDataSource>(),
      ),
    );
  }

  // USE CASE
  if (!sl.isRegistered<SubmitDealerActivity>()) {
    sl.registerLazySingleton<SubmitDealerActivity>(
      () => SubmitDealerActivity(
        sl<DealerActivityRepository>(),
      ),
    );
  }

  // BLOC
  if (!sl.isRegistered<DealerActivityBloc>()) {
    sl.registerFactory<DealerActivityBloc>(
      () => DealerActivityBloc(
        sl<SubmitDealerActivity>(),
      ),
    );
  }
}