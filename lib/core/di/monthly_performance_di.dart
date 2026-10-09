

// ============================================================
// GET IT
// ============================================================

import 'package:get_it/get_it.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/reports/data/datasources/monthly_performance_remote_datasource.dart';
import 'package:solufine/features/reports/data/repositories/monthly_performance_repository_impl.dart';
import 'package:solufine/features/reports/domain/repositories/monthly_performance_repository.dart';
import 'package:solufine/features/reports/domain/usecases/get_application_phase_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_area_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_daily_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_expense_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_hourly_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_monthly_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_report_financial_years.dart';
import 'package:solufine/features/reports/domain/usecases/get_top_dealer_performance_usecase.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_bloc.dart';

final GetIt sl =
    GetIt.instance;

// ============================================================
// MONTHLY PERFORMANCE DI
// ============================================================

Future<void>
    initMonthlyPerformanceDi() async {
  // ==========================================================
  // REMOTE DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<
      MonthlyPerformanceRemoteDataSource>()) {
    sl.registerLazySingleton<
        MonthlyPerformanceRemoteDataSource>(
      () =>
          MonthlyPerformanceRemoteDataSourceImpl(
        dioClient:
            DioClient(),
      ),
    );
  }

  // ==========================================================
  // REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<
      MonthlyPerformanceRepository>()) {
    sl.registerLazySingleton<
        MonthlyPerformanceRepository>(
      () =>
          MonthlyPerformanceRepositoryImpl(
        remoteDataSource:
            sl<
                MonthlyPerformanceRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // APPLICATION PHASE
  // ==========================================================

  if (!sl.isRegistered<
      GetApplicationPhaseUseCase>()) {
    sl.registerLazySingleton<
        GetApplicationPhaseUseCase>(
      () =>
          GetApplicationPhaseUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // FINANCIAL YEAR
  // ==========================================================

  if (!sl.isRegistered<
      GetReportFinancialYears>()) {
    sl.registerLazySingleton<
        GetReportFinancialYears>(
      () =>
          GetReportFinancialYears(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // MONTHLY
  // ==========================================================

  if (!sl.isRegistered<
      GetMonthlyPerformanceUseCase>()) {
    sl.registerLazySingleton<
        GetMonthlyPerformanceUseCase>(
      () =>
          GetMonthlyPerformanceUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // DAILY
  // ==========================================================

  if (!sl.isRegistered<
      GetDailyPerformanceUseCase>()) {
    sl.registerLazySingleton<
        GetDailyPerformanceUseCase>(
      () =>
          GetDailyPerformanceUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // HOURLY
  // ==========================================================

  if (!sl.isRegistered<
      GetHourlyPerformanceUseCase>()) {
    sl.registerLazySingleton<
        GetHourlyPerformanceUseCase>(
      () =>
          GetHourlyPerformanceUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // AREA
  // ==========================================================

  if (!sl.isRegistered<
      GetAreaPerformanceUseCase>()) {
    sl.registerLazySingleton<
        GetAreaPerformanceUseCase>(
      () =>
          GetAreaPerformanceUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // TOP DEALER
  // ==========================================================

  if (!sl.isRegistered<
      GetTopDealerPerformanceUseCase>()) {
    sl.registerLazySingleton<
        GetTopDealerPerformanceUseCase>(
      () =>
          GetTopDealerPerformanceUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // EXPENSE
  // ==========================================================

  if (!sl.isRegistered<
      GetExpensePerformanceUseCase>()) {
    sl.registerLazySingleton<
        GetExpensePerformanceUseCase>(
      () =>
          GetExpensePerformanceUseCase(
        sl<
            MonthlyPerformanceRepository>(),
      ),
    );
  }

  // ==========================================================
  // BLOC
  // ==========================================================

  if (!sl.isRegistered<
      MonthlyPerformanceBloc>()) {
    sl.registerFactory<
        MonthlyPerformanceBloc>(
      () =>
          MonthlyPerformanceBloc(
        getApplicationPhaseUseCase:
            sl<
                GetApplicationPhaseUseCase>(),

        getMonthlyPerformanceUseCase:
            sl<
                GetMonthlyPerformanceUseCase>(),

        getReportFinancialYears:
            sl<
                GetReportFinancialYears>(),

        getDailyPerformanceUseCase:
            sl<
                GetDailyPerformanceUseCase>(),

        getHourlyPerformanceUseCase:
            sl<
                GetHourlyPerformanceUseCase>(),

        getAreaPerformanceUseCase:
            sl<
                GetAreaPerformanceUseCase>(),

        getTopDealerPerformanceUseCase:
            sl<
                GetTopDealerPerformanceUseCase>(),

        getExpensePerformanceUseCase:
            sl<
                GetExpensePerformanceUseCase>(),
      ),
    );
  }
}