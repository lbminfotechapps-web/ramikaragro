import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';

import 'package:solufine/features/followup/data/datasources/followup_remote_data_source.dart';
import 'package:solufine/features/followup/data/repositories/followup_repository_impl.dart';

import 'package:solufine/features/followup/domain/repositories/followup_repository.dart';
import 'package:solufine/features/followup/domain/usecases/get_followup.dart';


import 'package:solufine/features/followup/presentation/bloc/followup_bloc.dart';

import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initFollowupDi() async {
  // ============================================================
  // SECURE STORAGE
  // ============================================================

  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );
  }

  // ============================================================
  // DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<FollowupRemoteDataSource>()) {
    sl.registerLazySingleton<FollowupRemoteDataSource>(
      () => FollowupRemoteDataSourceImpl(
        dioClient: DioClient(),
      ),
    );
  }

  // ============================================================
  // REPOSITORY
  // ============================================================

  if (!sl.isRegistered<FollowupRepository>()) {
    sl.registerLazySingleton<FollowupRepository>(
      () => FollowupRepositoryImpl(
        remoteDataSource:
            sl<FollowupRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // GET UPCOMING FOLLOWUP USE CASE
  // ============================================================

  if (!sl.isRegistered<GetUpcomingFollowup>()) {
    sl.registerLazySingleton<GetUpcomingFollowup>(
      () => GetUpcomingFollowup(
        sl<FollowupRepository>(),
      ),
    );
  }

  // ============================================================
  // FOLLOWUP BLOC
  // ============================================================

  if (!sl.isRegistered<FollowupBloc>()) {
    sl.registerFactory<FollowupBloc>(
      () => FollowupBloc(
        getUpcomingFollowup:
            sl<GetUpcomingFollowup>(),
      ),
    );
  }
}