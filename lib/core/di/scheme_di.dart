import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/scheme/data/datatsource/scheme_datasource.dart';
import 'package:demo/features/scheme/data/repoimp/schemerepository_impl.dart';
import 'package:demo/features/scheme/domain/repository/schemerepository.dart';
import 'package:demo/features/scheme/domain/usercases/schemeusecase.dart';
import 'package:demo/features/scheme/presentation/bloc/scheme_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initSchemeDi() async {
  // =========================
  // DATA SOURCE
  // =========================
  sl.registerLazySingleton<SchemeRemoteDataSource>(
    () => SchemeRemoteDataSource(dioClient: sl<DioClient>()),
  );

  // =========================
  // REPOSITORY
  // =========================
  sl.registerLazySingleton<SchemeRepository>(
    () => SchemeRepositoryImpl(remoteDataSource: sl<SchemeRemoteDataSource>()),
  );

  // =========================
  // USE CASE
  // =========================
  sl.registerLazySingleton<GetSchemeUseCase>(
    () => GetSchemeUseCase(repository: sl<SchemeRepository>()),
  );

  // =========================
  // BLOC
  // =========================
  sl.registerFactory<SchemeBloc>(
    () => SchemeBloc(getSchemeUseCase: sl<GetSchemeUseCase>()),
  );
}
