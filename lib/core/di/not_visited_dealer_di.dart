
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/di/auth_di.dart';


import 'package:demo/features/reports/data/datasources/not_visited_dealer_remote_data_source.dart';
import 'package:demo/features/reports/data/repositories/not_visited_dealer_repository_impl.dart';

import 'package:demo/features/reports/domain/repositories/not_visited_dealer_repository.dart';
import 'package:demo/features/reports/domain/usecases/get_not_visited_dealers.dart';

import 'package:demo/features/reports/presentation/bloc/not_visited_dealer_bloc.dart';

Future<void> initNotVisitedDealerDi() async {
  // ============================================================
  // DATA SOURCE
  // ============================================================

  sl.registerLazySingleton<NotVisitedDealerRemoteDataSource>(
    () => NotVisitedDealerRemoteDataSource(
      dioClient: sl<DioClient>(),
    ),
  );

  // ============================================================
  // REPOSITORY
  // ============================================================

  sl.registerLazySingleton<NotVisitedDealerRepository>(
    () => NotVisitedDealerRepositoryImpl(
      remoteDataSource: sl<NotVisitedDealerRemoteDataSource>(),
    ),
  );

  // ============================================================
  // USE CASE
  // ============================================================

  sl.registerLazySingleton<GetNotVisitedDealers>(
    () => GetNotVisitedDealers(
      repository: sl<NotVisitedDealerRepository>(),
    ),
  );

  // ============================================================
  // BLOC
  // ============================================================

  sl.registerFactory<NotVisitedDealerBloc>(
    () => NotVisitedDealerBloc(
      sl<GetNotVisitedDealers>(),
    ),
  );
}

