import 'package:get_it/get_it.dart';

import 'package:demo/core/api_constant/dio_client.dart';

import 'package:demo/features/reports/data/datasources/dealer_remote_data_source.dart';
import 'package:demo/features/reports/data/repositories/dealer_repository_impl.dart';

import 'package:demo/features/reports/domain/repositories/dealer_repository.dart';
import 'package:demo/features/reports/domain/usecases/get_not_visited_dealers.dart';

import 'package:demo/features/reports/presentation/bloc/not_visited_dealer_bloc.dart';

final sl = GetIt.instance;

Future<void> initDealerDi() async {

  // =========================
  // DATA SOURCE
  // =========================

  sl.registerLazySingleton<DealerRemoteDataSource>(
    () => DealerRemoteDataSource(
      sl<DioClient>(),
    ),
  );

  // =========================
  // REPOSITORY
  // =========================

  sl.registerLazySingleton<DealerRepository>(
    () => DealerRepositoryImpl(
      sl<DealerRemoteDataSource>(),
    ),
  );

  // =========================
  // USE CASE
  // =========================

  sl.registerLazySingleton<GetNotVisitedDealers>(
    () => GetNotVisitedDealers(
      sl<DealerRepository>(),
    ),
  );

  // =========================
  // BLOC
  // =========================

  sl.registerFactory<NotVisitedDealerBloc>(
    () => NotVisitedDealerBloc(
      sl<GetNotVisitedDealers>(),
    ),
  );
}