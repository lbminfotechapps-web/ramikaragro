

// ============================================================
// VISIT MONTH WISE DI
// ============================================================

import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/features/visit_month_wise/data/datasources/visit_month_wise_remote_datasource.dart';
import 'package:solufine/features/visit_month_wise/data/repositories/visit_month_wise_repository_impl.dart';
import 'package:solufine/features/visit_month_wise/domain/repositories/visit_month_wise_repository.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_day_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_frequency_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_geo_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_hour_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_month_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_report_employees_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_top_employee_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_top_list_usecase.dart';
import 'package:solufine/features/visit_month_wise/presentation/bloc/visit_month_wise_bloc.dart';

Future<void> initVisitMonthWiseDi() async {
  // ==========================================================
  // REMOTE DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<VisitMonthWiseRemoteDataSource>()) {
    sl.registerLazySingleton<
        VisitMonthWiseRemoteDataSource>(
      () => VisitMonthWiseRemoteDataSourceImpl(
        dioClient: sl(),
      ),
    );
  }

  // ==========================================================
  // REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<VisitMonthWiseRepository>()) {
    sl.registerLazySingleton<
        VisitMonthWiseRepository>(
      () => VisitMonthWiseRepositoryImpl(
        remoteDataSource:
            sl<VisitMonthWiseRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // MONTH WISE
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitMonthWiseUseCase>()) {
    sl.registerLazySingleton<
        GetVisitMonthWiseUseCase>(
      () => GetVisitMonthWiseUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // DAY WISE
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitDayWiseUseCase>()) {
    sl.registerLazySingleton<
        GetVisitDayWiseUseCase>(
      () => GetVisitDayWiseUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // HOUR WISE
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitHourWiseUseCase>()) {
    sl.registerLazySingleton<
        GetVisitHourWiseUseCase>(
      () => GetVisitHourWiseUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // FREQUENCY
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitFrequencyUseCase>()) {
    sl.registerLazySingleton<
        GetVisitFrequencyUseCase>(
      () => GetVisitFrequencyUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // GEO WISE
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitGeoWiseUseCase>()) {
    sl.registerLazySingleton<
        GetVisitGeoWiseUseCase>(
      () => GetVisitGeoWiseUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // TOP DEALER / FARMER
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitTopListUseCase>()) {
    sl.registerLazySingleton<
        GetVisitTopListUseCase>(
      () => GetVisitTopListUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // TOP EMPLOYEE
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitTopEmployeeUseCase>()) {
    sl.registerLazySingleton<
        GetVisitTopEmployeeUseCase>(
      () => GetVisitTopEmployeeUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // EMPLOYEE SEARCH
  // ==========================================================

  if (!sl.isRegistered<
      GetVisitReportEmployeesUseCase>()) {
    sl.registerLazySingleton<
        GetVisitReportEmployeesUseCase>(
      () => GetVisitReportEmployeesUseCase(
        sl<VisitMonthWiseRepository>(),
      ),
    );
  }

  // ==========================================================
  // BLOC
  // ==========================================================

  if (!sl.isRegistered<VisitMonthWiseBloc>()) {
    sl.registerFactory<VisitMonthWiseBloc>(
      () => VisitMonthWiseBloc(
        getVisitMonthWiseUseCase:
            sl<GetVisitMonthWiseUseCase>(),

        getVisitDayWiseUseCase:
            sl<GetVisitDayWiseUseCase>(),

        getVisitHourWiseUseCase:
            sl<GetVisitHourWiseUseCase>(),

        getVisitFrequencyUseCase:
            sl<GetVisitFrequencyUseCase>(),

        getVisitGeoWiseUseCase:
            sl<GetVisitGeoWiseUseCase>(),

        getVisitTopListUseCase:
            sl<GetVisitTopListUseCase>(),

        getVisitTopEmployeeUseCase:
            sl<GetVisitTopEmployeeUseCase>(),

        getVisitReportEmployeesUseCase:
            sl<GetVisitReportEmployeesUseCase>(),
      ),
    );
  }
}