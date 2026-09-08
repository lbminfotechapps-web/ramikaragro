import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/famerfollowup/data/datasource/famerfollowup_datasource.dart';
import 'package:demo/features/farmer/famerfollowup/data/repoimp/famerfollowuprepository_Imp.dart';
import 'package:demo/features/farmer/famerfollowup/domain/repository/famerfollowup_repository.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_bloc.dart';
import 'package:demo/features/farmer/farmerlist/data/datasource/farmerlist_datasource.dart';
import 'package:demo/features/farmer/farmerlist/data/repoimp/farmer_repo_imp.dart';
import 'package:demo/features/farmer/farmerlist/domain/repository/farmerlist_repo.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initFarmerDi() async {
  // =========================
  // DATA SOURCE
  // =========================
  sl.registerLazySingleton<FarmerListDataSource>(
    () => FarmerListDataSource(dioClient: sl<DioClient>()),
  );

  // =========================
  // REPOSITORY
  // =========================
  sl.registerLazySingleton<FarmerListRepository>(
    () => FarmerListRepositoryImpl(sl<FarmerListDataSource>()),
  );

  // =========================
  // BLOC
  // =========================
  sl.registerFactory<FarmerListBloc>(
    () => FarmerListBloc(repository: sl<FarmerListRepository>()),
  );

  // =========================
  // DATA SOURCE
  // =========================
  sl.registerLazySingleton<FamerfollowupDatasource>(
    () => FamerfollowupDatasource(dioClient: sl<DioClient>()),
  );

  // =========================
  // REPOSITORY
  // =========================
  sl.registerLazySingleton<FamerfollowupRepository>(
    () => FamerfollowupRepositoryImpl(sl<FamerfollowupDatasource>()),
  );

  // =========================
  // BLOC
  // =========================
  sl.registerFactory<FamerfollowupBloc>(
    () => FamerfollowupBloc(repository: sl<FamerfollowupRepository>()),
  );
}
