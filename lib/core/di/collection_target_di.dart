import 'package:demo/features/collection/data/datasources/dealer_target_remote_datasource.dart';
import 'package:demo/features/collection/data/repositories/dealer_target_repository_impl.dart';
import 'package:demo/features/collection/domain/repositories/dealer_target_repository.dart';
import 'package:demo/features/collection/domain/usecases/get_collection_wise_target.dart';
import 'package:demo/features/collection/domain/usecases/get_target_dates.dart';
import 'package:demo/features/collection/presentation/bloc/dealer_target_bloc.dart';
import 'package:get_it/get_it.dart';

import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initDealerTargetDi() async {
  // -----------------------------------
  // DATA SOURCE
  // -----------------------------------

  if (!sl.isRegistered<DealerTargetRemoteDataSource>()) {
    sl.registerLazySingleton<DealerTargetRemoteDataSource>(
      () => DealerTargetRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // -----------------------------------
  // REPOSITORY
  // -----------------------------------

  if (!sl.isRegistered<DealerTargetRepository>()) {
    sl.registerLazySingleton<DealerTargetRepository>(
      () => DealerTargetRepositoryImpl(
        remoteDataSource:
            sl<DealerTargetRemoteDataSource>(),
      ),
    );
  }

  // -----------------------------------
  // USE CASE
  // -----------------------------------

  if (!sl.isRegistered<GetTargetDates>()) {
    sl.registerLazySingleton<GetTargetDates>(
      () => GetTargetDates(
        repository:
            sl<DealerTargetRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<GetCollectionWiseTarget>()) {
    sl.registerLazySingleton<GetCollectionWiseTarget>(
      () => GetCollectionWiseTarget(
        repository:
            sl<DealerTargetRepository>(),
      ),
    );
  }

  // -----------------------------------
  // BLOC
  // -----------------------------------

  if (!sl.isRegistered<DealerTargetBloc>()) {
    sl.registerFactory<DealerTargetBloc>(
      () => DealerTargetBloc(
        getTargetDates:
            sl<GetTargetDates>(),
        getCollectionWiseTarget:
            sl<GetCollectionWiseTarget>(),
      ),
    );
  }
}