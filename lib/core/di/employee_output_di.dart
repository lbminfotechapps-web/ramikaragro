import 'package:get_it/get_it.dart';

import 'package:demo/core/api_constant/dio_client.dart';

import 'package:demo/features/reports/data/datasources/employee_output_remote_data_source.dart';

import 'package:demo/features/reports/data/repositories/employee_output_repository_impl.dart';

import 'package:demo/features/reports/domain/repositories/employee_output_repository.dart';

import 'package:demo/features/reports/domain/usecases/get_employee_output_report.dart';

import 'package:demo/features/reports/domain/usecases/get_employees.dart';

import 'package:demo/features/reports/presentation/bloc/employee_output_bloc.dart';

final sl = GetIt.instance;

Future<void> initEmployeeOutputDi() async {
  // ============================================================
  // DATA SOURCE
  // ============================================================

  sl.registerLazySingleton<
      EmployeeOutputRemoteDataSource>(
    () => EmployeeOutputRemoteDataSource(
      sl<DioClient>(),
    ),
  );

  // ============================================================
  // REPOSITORY
  // ============================================================

  sl.registerLazySingleton<
      EmployeeOutputRepository>(
    () => EmployeeOutputRepositoryImpl(
      sl<EmployeeOutputRemoteDataSource>(),
    ),
  );

  // ============================================================
  // REPORT USE CASE
  // ============================================================

  sl.registerLazySingleton<
      GetEmployeeOutputReport>(
    () => GetEmployeeOutputReport(
      sl<EmployeeOutputRepository>(),
    ),
  );

  // ============================================================
  // EMPLOYEE SEARCH USE CASE
  // ============================================================

  sl.registerLazySingleton<GetEmployees>(
    () => GetEmployees(
      sl<EmployeeOutputRepository>(),
    ),
  );

  // ============================================================
  // BLOC
  // ============================================================

  sl.registerFactory<EmployeeOutputBloc>(
    () => EmployeeOutputBloc(
      getEmployeeOutputReport:
          sl<GetEmployeeOutputReport>(),

      getEmployees:
          sl<GetEmployees>(),
    ),
  );
}