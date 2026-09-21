import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';

import 'package:solufine/features/reports/data/datasources/employee_activity_remote_data_source.dart';

import 'package:solufine/features/reports/data/repositories/employee_activity_repository_impl.dart';

import 'package:solufine/features/reports/domain/repositories/employee_activity_repository.dart';

import 'package:solufine/features/reports/domain/usecases/get_employee_activity_details.dart';

import 'package:solufine/features/reports/presentation/bloc/employee_activity_bloc.dart';

final sl = GetIt.instance;

Future<void> initEmployeeActivityDi() async {

  // ==========================================
  // DATA SOURCE
  // ==========================================

  sl.registerLazySingleton<
      EmployeeActivityRemoteDataSource>(
    () => EmployeeActivityRemoteDataSource(
      sl<DioClient>(),
    ),
  );

  // ==========================================
  // REPOSITORY
  // ==========================================

  sl.registerLazySingleton<
      EmployeeActivityRepository>(
    () => EmployeeActivityRepositoryImpl(
      sl<EmployeeActivityRemoteDataSource>(),
    ),
  );

  // ==========================================
  // USE CASE
  // ==========================================

  sl.registerLazySingleton<
      GetEmployeeActivityDetails>(
    () => GetEmployeeActivityDetails(
      sl<EmployeeActivityRepository>(),
    ),
  );

  // ==========================================
  // BLOC
  // ==========================================

  sl.registerFactory<
      EmployeeActivityBloc>(
    () => EmployeeActivityBloc(
      sl<GetEmployeeActivityDetails>(),
    ),
  );
}