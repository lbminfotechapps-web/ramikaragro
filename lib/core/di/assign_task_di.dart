
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/assigntask/data/datasources/task_remote_data_source.dart';
import 'package:solufine/features/assigntask/data/repositories/task_repository_impl.dart';
import 'package:solufine/features/assigntask/domain/repositories/task_repository.dart';
import 'package:solufine/features/assigntask/domain/usecases/task_usecases.dart';
import 'package:solufine/features/assigntask/presentation/bloc/task_bloc.dart';

import 'package:solufine/features/reports/domain/usecases/get_employees.dart'
    as reports;



final sl = GetIt.instance;

Future<void> initAssignTaskDi() async {
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  if (!sl.isRegistered<TaskRemoteDataSource>()) {
    sl.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // Reports GetEmployees must already be registered
  // by your Reports module.
  if (!sl.isRegistered<TaskRepository>()) {
    sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
        remote: sl<TaskRemoteDataSource>(),
        searchEmployees: sl<reports.GetEmployees>(),
      ),
    );
  }

  // =====================================================
// ASSIGN TASK GET EMPLOYEES USE CASE
// =====================================================

if (!sl.isRegistered<GetEmployees>()) {
  sl.registerLazySingleton<GetEmployees>(
    () => GetEmployees(
      sl<TaskRepository>(),
    ),
  );
}
  if (!sl.isRegistered<GetTasks>()) {
    sl.registerLazySingleton<GetTasks>(
      () => GetTasks(sl<TaskRepository>()),
    );
  }

  if (!sl.isRegistered<CreateTask>()) {
    sl.registerLazySingleton<CreateTask>(
      () => CreateTask(sl<TaskRepository>()),
    );
  }

  if (!sl.isRegistered<CompleteTask>()) {
    sl.registerLazySingleton<CompleteTask>(
      () => CompleteTask(sl<TaskRepository>()),
    );
  }

  if (!sl.isRegistered<TaskBloc>()) {
    sl.registerFactory<TaskBloc>(
      () => TaskBloc(
        getEmployees: sl<GetEmployees>(),
        getTasks: sl<GetTasks>(),
        createTask: sl<CreateTask>(),
        completeTask: sl<CompleteTask>(),
      ),
    );
  }
}
