
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/assigntask/data/datasources/assigned_task_remote_data_source.dart';
import 'package:solufine/features/assigntask/data/repositories/assigned_task_repository_impl.dart';
import 'package:solufine/features/assigntask/domain/repositories/assigned_task_repository.dart';
import 'package:solufine/features/assigntask/presentation/bloc/assigned_task_bloc.dart';



final sl = GetIt.instance;

Future<void> initAssignedTaskDi() async {

  // ==========================================
  // DIO CLIENT
  // ==========================================
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ==========================================
  // REMOTE DATA SOURCE
  // ==========================================
  if (!sl.isRegistered<AssignedTaskRemoteDataSource>()) {
    sl.registerLazySingleton<AssignedTaskRemoteDataSource>(
      () => AssignedTaskRemoteDataSourceImpl(
        sl<DioClient>().client,
      ),
    );
  }

  // ==========================================
  // REPOSITORY
  // ==========================================
  if (!sl.isRegistered<AssignedTaskRepository>()) {
    sl.registerLazySingleton<AssignedTaskRepository>(
      () => AssignedTaskRepositoryImpl(
        sl<AssignedTaskRemoteDataSource>(),
      ),
    );
  }

  // ==========================================
  // ASSIGNED TASK BLOC
  // ==========================================
  

if (!sl.isRegistered<AssignedTaskBloc>()) {
  sl.registerFactory<AssignedTaskBloc>(
    () => AssignedTaskBloc(
      repository: sl<AssignedTaskRepository>(),
    ),
  );
}


}
