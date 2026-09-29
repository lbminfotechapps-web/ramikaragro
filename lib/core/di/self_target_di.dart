import 'package:get_it/get_it.dart';
import 'package:solufine/features/assign_target_point_wise/data/datasources/self_target_remote_datasource.dart';
import 'package:solufine/features/assign_target_point_wise/data/repositories/self_target_repository_impl.dart';
import 'package:solufine/features/assign_target_point_wise/domain/repositories/self_target_repository.dart';
import 'package:solufine/features/assign_target_point_wise/domain/usecases/get_self_target.dart';
import 'package:solufine/features/assign_target_point_wise/domain/usecases/submit_self_target.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_bloc.dart';



import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initSelfTargetDi() async {
  // ============================================================
  // DATASOURCE
  // ============================================================

  sl.registerLazySingleton<
      SelfTargetRemoteDataSource>(
    () =>
        SelfTargetRemoteDataSourceImpl(
      dioClient:
          sl<DioClient>(),
    ),
  );

  // ============================================================
  // REPOSITORY
  // ============================================================

  sl.registerLazySingleton<
      SelfTargetRepository>(
    () =>
        SelfTargetRepositoryImpl(
      remoteDataSource:
          sl<SelfTargetRemoteDataSource>(),
    ),
  );

  // ============================================================
  // GET SELF TARGET USE CASE
  // ============================================================

  sl.registerLazySingleton<
      GetSelfTarget>(
    () =>
        GetSelfTarget(
      repository:
          sl<SelfTargetRepository>(),
    ),
  );

  // ============================================================
  // SUBMIT SELF TARGET USE CASE
  // ============================================================

  sl.registerLazySingleton<
      SubmitSelfTarget>(
    () =>
        SubmitSelfTarget(
      repository:
          sl<SelfTargetRepository>(),
    ),
  );

  // ============================================================
  // BLOC
  // ============================================================

  sl.registerFactory<
      SelfTargetBloc>(
    () =>
        SelfTargetBloc(
      getSelfTarget:
          sl<GetSelfTarget>(),

      submitSelfTarget:
          sl<SubmitSelfTarget>(),
    ),
  );
}