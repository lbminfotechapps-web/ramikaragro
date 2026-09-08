
import 'package:demo/features/leave/data/datasources/team_leave_remote_datasource.dart';
import 'package:demo/features/leave/data/repositories/team_leave_repository_impl.dart';
import 'package:demo/features/leave/domain/repositories/team_leave_repository.dart';
import 'package:demo/features/leave/domain/usecases/get_team_leave_list.dart';
import 'package:demo/features/leave/domain/usecases/update_team_leave_status.dart';
import 'package:demo/features/leave/presentation/bloc/team_leave_bloc.dart';
import 'package:get_it/get_it.dart';

import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initTeamLeaveDi() async {
  // DATA SOURCE
  sl.registerLazySingleton<TeamLeaveRemoteDataSource>(
    () => TeamLeaveRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  // REPOSITORY
  sl.registerLazySingleton<TeamLeaveRepository>(
    () => TeamLeaveRepositoryImpl(
      remoteDataSource:
          sl<TeamLeaveRemoteDataSource>(),
    ),
  );

  // GET LIST USE CASE
  sl.registerLazySingleton<GetTeamLeaveList>(
    () => GetTeamLeaveList(
      repository: sl<TeamLeaveRepository>(),
    ),
  );

  // UPDATE STATUS USE CASE
  sl.registerLazySingleton<UpdateTeamLeaveStatus>(
    () => UpdateTeamLeaveStatus(
      repository: sl<TeamLeaveRepository>(),
    ),
  );

  // BLOC
  sl.registerFactory<TeamLeaveBloc>(
    () => TeamLeaveBloc(
      getTeamLeaveList:
          sl<GetTeamLeaveList>(),
      updateTeamLeaveStatus:
          sl<UpdateTeamLeaveStatus>(),
    ),
  );
}