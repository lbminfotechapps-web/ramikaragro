import 'package:demo/features/dealer/data/datasource/dealer_datasource.dart';
import 'package:demo/features/dealer/data/repoimp/dealer_repo_imp.dart';
import 'package:demo/features/dealer/domain/repository/dealer_repo.dart';
import 'package:demo/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:demo/core/api_constant/dio_client.dart';




// Future<void> initDealerDi() async {

//   // =========================
//   // DATA SOURCE
//   // =========================

//   sl.registerLazySingleton<DealerRemoteDataSource>(
//     () => DealerRemoteDataSource(
//       sl<DioClient>(),
//     ),
//   );

//   // =========================
//   // REPOSITORY
//   // =========================

//   sl.registerLazySingleton<DealerRepository>(
//     () => DealerRepositoryImpl(
//       sl<DealerRemoteDataSource>(),
//     ),
//   );

//   // =========================
//   // USE CASE
//   // =========================

//   sl.registerLazySingleton<GetNotVisitedDealers>(
//     () => GetNotVisitedDealers(
//       sl<DealerRepository>(),
//     ),
//   );

//   // =========================
//   // BLOC
//   // =========================

//   sl.registerFactory<NotVisitedDealerBloc>(
//     () => NotVisitedDealerBloc(
//       sl<GetNotVisitedDealers>(),
//     ),
//   );
// }

final sl = GetIt.instance;

Future<void> initDealerDi() async {
  // =========================
  // DATA SOURCE
  // =========================
  sl.registerLazySingleton<DealerListDataSource>(
    () => DealerListDataSource(
      dioClient: sl<DioClient>(),
    ),
  );

  // =========================
  // REPOSITORY
  // =========================
  sl.registerLazySingleton<DealerListRepository>(
    () => DealerListRepositoryImpl(
      sl<DealerListDataSource>(),
    ),
  );

  // =========================
  // BLOC
  // =========================
  sl.registerFactory<DealerListBloc>(
    () => DealerListBloc(
      repository: sl<DealerListRepository>(),
    ),
  );
}